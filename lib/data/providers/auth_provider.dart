import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/services/api_service.dart';
import '../models/app_models.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService api;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final LocalAuthentication localAuth = LocalAuthentication();

  AuthProvider(this.api);

  AppUser? user;
  String? token;
  List<String> modulosPermitidos = [];

  bool isLoading = false;
  bool isRestoringSession = true;
  bool biometricEnabled = false;

  bool get isLoggedIn => user != null && token != null;
  bool tieneModulo(String ruta) {
    return modulosPermitidos.contains(ruta);
  }

  Future<void> restoreSession() async {
    isRestoringSession = true;
    notifyListeners();

    try {
      biometricEnabled =
          await secureStorage.read(key: 'biometric_enabled') == '1';

      final savedToken = await secureStorage.read(key: 'token');
      final savedUser = await secureStorage.read(key: 'usuario');
      final savedUserId = await secureStorage.read(key: 'user_id');
      final savedModulos = await secureStorage.read(key: 'modulos');

      if (savedToken != null &&
          savedToken.isNotEmpty &&
          savedUser != null &&
          savedUser.isNotEmpty) {
        token = savedToken;

        final List<dynamic> modulosJson = savedModulos != null && savedModulos.isNotEmpty
            ? jsonDecode(savedModulos)
            : [];
        
        modulosPermitidos = modulosJson
            .map((m) => m.toString())
            .where((m) => m.isNotEmpty)
            .toList();
        
        user = AppUser(
          id: int.tryParse(savedUserId ?? '0') ?? 0,
          usuario: savedUser,
          nombres: await secureStorage.read(key: 'nombres') ?? '',
          apellidos: await secureStorage.read(key: 'apellidos') ?? '',
          rol: await secureStorage.read(key: 'rol') ?? '',
          activo: true,
          modulos: modulosPermitidos,
        );
      } else {
        token = null;
        user = null;
      }
    } catch (e) {
      debugPrint('ERROR RESTORE SESSION: $e');
      token = null;
      user = null;
    } finally {
      isRestoringSession = false;
      notifyListeners();
    }
  }

  Future<void> login(String usuario, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await api.dio.post(
        'login.php',
        data: {
          'usuario': usuario,
          'password': password,
        },
      );

      final data = Map<String, dynamic>.from(res.data);

      final bool loginCorrecto =
          data['success'] == true || data['ok'] == true;

      if (!loginCorrecto) {
        throw Exception(
          data['message'] ?? data['msg'] ?? 'No se pudo iniciar sesión',
        );
      }

      final userData = Map<String, dynamic>.from(data['user']);
      
      //debugPrint('USER DATA LOGIN: $userData');
//debugPrint('MODULOS LOGIN RAW: ${userData['modulos']}');

      final List<dynamic> modulos = userData['modulos'] is List
          ? List<dynamic>.from(userData['modulos'])
          : [];
      
      modulosPermitidos = modulos
          .map((m) {
            if (m is Map) {
              return m['ruta']?.toString() ?? '';
            }
            return '';
          })
          .where((ruta) => ruta.isNotEmpty)
          .toList();

          //debugPrint('MODULOS PERMITIDOS FINAL: $modulosPermitidos');
      
      token = data['token']?.toString();

      token ??= 'LOCAL_TOKEN_${userData['id']}_${DateTime.now().millisecondsSinceEpoch}';

      user = AppUser(
        id: int.tryParse(userData['id'].toString()) ?? 0,
        usuario: userData['usuario']?.toString() ?? '',
        nombres: userData['nombres']?.toString() ?? '',
        apellidos: userData['apellidos']?.toString() ?? '',
        rol: userData['rol']?.toString() ?? '',
        activo: true,
        modulos: modulosPermitidos,
      );

      await _saveSession(password);
    } on DioException catch (e) {
      debugPrint('ERROR LOGIN DIO: ${e.response?.data}');
      debugPrint('ERROR LOGIN MESSAGE: ${e.message}');

      String mensaje = 'Error de conexión';

      final responseData = e.response?.data;

      if (responseData is Map) {
        mensaje = responseData['message']?.toString() ??
            responseData['msg']?.toString() ??
            mensaje;
      } else if (e.message != null) {
        mensaje = e.message!;
      }

      throw Exception(mensaje);
    } catch (e) {
      debugPrint('ERROR LOGIN GENERAL: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSession(String password) async {
    if (user == null || token == null) return;

    await secureStorage.write(key: 'token', value: token);
    await secureStorage.write(key: 'user_id', value: user!.id.toString());
    await secureStorage.write(key: 'usuario', value: user!.usuario);
    await secureStorage.write(key: 'nombres', value: user!.nombres);
    await secureStorage.write(key: 'apellidos', value: user!.apellidos);
    await secureStorage.write(key: 'rol', value: user!.rol);
    await secureStorage.write(
      key: 'modulos',
      value: jsonEncode(modulosPermitidos),
    );

    await secureStorage.write(key: 'password', value: password);

    final existeConfigHuella =
        await secureStorage.read(key: 'biometric_enabled');

    if (existeConfigHuella == null) {
      await secureStorage.write(key: 'biometric_enabled', value: '0');
      biometricEnabled = false;
    }
  }

  Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await localAuth.canCheckBiometrics;
      final supported = await localAuth.isDeviceSupported();

      return canCheck || supported;
    } catch (e) {
      debugPrint('ERROR CAN BIOMETRICS: $e');
      return false;
    }
  }

  Future<bool> requestEnableBiometric() async {
    try {
      final canUse = await canUseBiometrics();

      if (!canUse) return false;

      final ok = await localAuth.authenticate(
        localizedReason: 'Confirma tu huella para activar el ingreso biométrico',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (ok) {
        await setBiometricEnabled(true);
        return true;
      }

      await setBiometricEnabled(false);
      return false;
    } catch (e) {
      debugPrint('ERROR REQUEST ENABLE BIOMETRIC: $e');
      await setBiometricEnabled(false);
      return false;
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    biometricEnabled = enabled;

    await secureStorage.write(
      key: 'biometric_enabled',
      value: enabled ? '1' : '0',
    );

    notifyListeners();
  }

  Future<bool> biometricLogin() async {
    try {
      final enabled = await secureStorage.read(key: 'biometric_enabled') == '1';

      if (!enabled) return false;

      final ok = await localAuth.authenticate(
        localizedReason: 'Confirma tu identidad para ingresar a SEFAB',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (!ok) return false;

      final usuario = await secureStorage.read(key: 'usuario');
      final password = await secureStorage.read(key: 'password');

      if (usuario == null || password == null) return false;

      await login(usuario, password);

      return true;
    } catch (e) {
      debugPrint('ERROR BIOMETRIC LOGIN: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'token');
    await secureStorage.delete(key: 'user_id');
    await secureStorage.delete(key: 'usuario');
    await secureStorage.delete(key: 'nombres');
    await secureStorage.delete(key: 'apellidos');
    await secureStorage.delete(key: 'rol');
    await secureStorage.delete(key: 'modulos');

    token = null;
    user = null;

    modulosPermitidos = [];

    notifyListeners();
  }
}
