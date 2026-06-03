import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/config/app_config.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': AppConfig.apiKey,
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.plain,
    ),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<Map<String, dynamic>> login({
    required String usuario,
    required String password,
  }) async {
    try {
      //debugPrint('URL LOGIN: ${AppConfig.baseUrl}/login.php');
      //debugPrint('USUARIO ENVIADO: $usuario');

      final response = await _dio.post(
        '/login.php',
        data: {
          'usuario': usuario,
          'password': password,
        },
      );

      //debugPrint('STATUS CODE: ${response.statusCode}');
      //debugPrint('RESPUESTA LOGIN: ${response.data}');

      //debugPrint('RESPUESTA CRUDA PHP: ${response.data}');

      final data = jsonDecode(response.data.toString());

      if (data is! Map<String, dynamic>) {
        return {
          'success': false,
          'message': 'Respuesta inválida del servidor',
        };
      }

      if (data['success'] == true) {
        final user = data['user'];

        final existeConfigHuella = await _storage.read(key: 'auth_enabled');

        if (existeConfigHuella == null) {
          await _storage.write(key: 'auth_enabled', value: '0');
        }
        await _storage.write(key: 'user_id', value: user['id'].toString());
        await _storage.write(key: 'usuario', value: user['usuario'] ?? '');
        await _storage.write(key: 'nombres', value: user['nombres'] ?? '');
        await _storage.write(key: 'apellidos', value: user['apellidos'] ?? '');
        await _storage.write(key: 'cod_rol', value: user['cod_rol'].toString());

        return {
          'success': true,
          'message': data['message'] ?? 'Login correcto',
          'user': user,
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'No se pudo iniciar sesión',
      };
    } on DioException catch (e) {
      debugPrint('ERROR DIO LOGIN MESSAGE: ${e.message}');
debugPrint('ERROR DIO LOGIN TYPE: ${e.type}');
debugPrint('ERROR DIO LOGIN ERROR: ${e.error}');
debugPrint('ERROR DIO LOGIN RESPONSE: ${e.response?.data}');
debugPrint('ERROR DIO LOGIN STATUS: ${e.response?.statusCode}');
debugPrint('ERROR DIO LOGIN STACK: ${e.stackTrace}');

      String mensaje = 'Error de conexión con el servidor.';

      if (e.type == DioExceptionType.connectionTimeout) {
        mensaje = 'Tiempo de conexión agotado. Revisa la IP del servidor.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        mensaje = 'El servidor demoró demasiado en responder.';
      } else if (e.type == DioExceptionType.connectionError) {
        mensaje = 'No se pudo conectar. Revisa WiFi, IP, firewall o Apache.';
      } else if (e.response?.statusCode == 404) {
        mensaje = 'No se encontró login.php. Revisa la URL.';
      } else if (e.response?.statusCode == 500) {
        mensaje = 'Error interno en PHP. Revisa login.php, db.php o la base de datos.';
      } else if (e.response?.data != null) {
        mensaje = e.response?.data.toString() ?? mensaje;
      }

      return {
        'success': false,
        'message': mensaje,
      };
    } catch (e) {
      debugPrint('ERROR GENERAL LOGIN: $e');

      return {
        'success': false,
        'message': 'Error inesperado: $e',
      };
    }
  }

  Future<bool> deviceSupportsBiometric() async {
  try {
    final disponible = await _localAuth.canCheckBiometrics;
    final soportado = await _localAuth.isDeviceSupported();

    return disponible && soportado;
  } catch (_) {
    return false;
  }
}

Future<bool> activarHuellaConValidacion() async {
  try {
    final puedeUsar = await deviceSupportsBiometric();

    if (!puedeUsar) {
      return false;
    }

    final autenticado = await _localAuth.authenticate(
      localizedReason: 'Confirma tu huella para activar el ingreso biométrico',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    if (autenticado) {
      await _storage.write(key: 'auth_enabled', value: '1');
      return true;
    }

    await _storage.write(key: 'auth_enabled', value: '0');
    return false;
  } catch (e) {
    debugPrint('ERROR ACTIVANDO HUELLA: $e');
    return false;
  }
}

  Future<bool> canUseBiometric() async {
    final disponible = await _localAuth.canCheckBiometrics;
    final soportado = await _localAuth.isDeviceSupported();
    final authEnabled = await _storage.read(key: 'auth_enabled');

    return disponible && soportado && authEnabled == '1';
  }

  Future<Map<String, dynamic>> loginWithBiometric() async {
    try {
      final puedeUsar = await canUseBiometric();

      if (!puedeUsar) {
        return {
          'success': false,
          'message':
              'Primero inicia sesión con usuario y contraseña para activar la huella.',
        };
      }

      final autenticado = await _localAuth.authenticate(
        localizedReason: 'Confirma tu huella para ingresar a SEFAB',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!autenticado) {
        return {
          'success': false,
          'message': 'Autenticación biométrica cancelada.',
        };
      }

      final usuario = await _storage.read(key: 'usuario');
      final nombres = await _storage.read(key: 'nombres');
      final apellidos = await _storage.read(key: 'apellidos');
      final codRol = await _storage.read(key: 'cod_rol');

      return {
        'success': true,
        'message': 'Ingreso biométrico correcto',
        'user': {
          'usuario': usuario,
          'nombres': nombres,
          'apellidos': apellidos,
          'cod_rol': int.tryParse(codRol ?? '0') ?? 0,
        },
      };
    } catch (e) {
      debugPrint('ERROR BIOMETRIA: $e');

      return {
        'success': false,
        'message': 'No se pudo validar la huella: $e',
      };
    }
  }

  Future<void> enableBiometricLogin() async {
    await _storage.write(key: 'auth_enabled', value: '1');
  }

  Future<void> disableBiometricLogin() async {
    await _storage.write(key: 'auth_enabled', value: '0');
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'auth_enabled');
    return value == '1';
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}