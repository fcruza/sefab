import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../../data/models/usuario_model.dart';
import '../../data/models/rol_model.dart';
import '../../data/models/modulo_model.dart';

class UsuarioService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 25),
      receiveTimeout: const Duration(seconds: 25),
      headers: {
        'X-API-KEY': AppConfig.apiKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<List<UsuarioModel>> listarUsuarios() async {
    try {
      final response = await _dio.get('/listar_usuarios.php');
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Respuesta inválida del servidor');
      }

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'No se pudo cargar usuarios');
      }

      final list = data['data'];

      if (list is! List) return [];

      return list
          .map((e) => UsuarioModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      final error = _manejarError(e);
      throw Exception(error['message'] ?? 'Error de conexión');
    }
  }

  Future<List<RolModel>> listarRoles() async {
    try {
      final response = await _dio.get('/listar_roles.php');
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Respuesta inválida del servidor');
      }

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'No se pudo cargar roles');
      }

      final list = data['data'];

      if (list is! List) return [];

      return list
          .map((e) => RolModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      final error = _manejarError(e);
      throw Exception(error['message'] ?? 'Error de conexión');
    }
  }

  Future<List<ModuloModel>> listarModulos() async {
    try {
      final response = await _dio.get('/listar_modulos.php');
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Respuesta inválida del servidor');
      }

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'No se pudo cargar módulos');
      }

      final list = data['data'];

      if (list is! List) return [];

      return list
          .map((e) => ModuloModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      final error = _manejarError(e);
      throw Exception(error['message'] ?? 'Error de conexión');
    }
  }

  Future<List<int>> listarUsuarioModulos(int usuarioId) async {
    try {
      final response = await _dio.get(
        '/listar_usuario_modulos.php',
        queryParameters: {
          'usuario_id': usuarioId,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Respuesta inválida del servidor');
      }

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'No se pudo cargar permisos');
      }

      final list = data['data'];

      if (list is! List) return [];

      return list
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((id) => id > 0)
          .toList();
    } on DioException catch (e) {
      final error = _manejarError(e);
      throw Exception(error['message'] ?? 'Error de conexión');
    }
  }

  Future<Map<String, dynamic>> guardarUsuario({
    required UsuarioModel usuario,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/guardar_usuario.php',
        data: usuario.toJson(password: password),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) return data;

      return {
        'success': false,
        'message': 'Respuesta inválida del servidor',
      };
    } on DioException catch (e) {
      return _manejarError(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado al guardar usuario: $e',
      };
    }
  }

  Future<Map<String, dynamic>> guardarUsuarioModulos({
    required int usuarioId,
    required List<int> modulos,
  }) async {
    try {
      final response = await _dio.post(
        '/guardar_usuario_modulos.php',
        data: {
          'usuario_id': usuarioId,
          'modulos': modulos,
        },
      );

      final data = response.data;

      if (data is Map<String, dynamic>) return data;

      return {
        'success': false,
        'message': 'Respuesta inválida del servidor',
      };
    } on DioException catch (e) {
      return _manejarError(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado al guardar permisos: $e',
      };
    }
  }

  Future<Map<String, dynamic>> cambiarEstadoUsuario({
    required int usuarioId,
    required int estado,
  }) async {
    try {
      final response = await _dio.post(
        '/cambiar_estado_usuario.php',
        data: {
          'id': usuarioId,
          'estado': estado,
        },
      );

      final data = response.data;

      if (data is Map<String, dynamic>) return data;

      return {
        'success': false,
        'message': 'Respuesta inválida del servidor',
      };
    } on DioException catch (e) {
      return _manejarError(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado al cambiar estado: $e',
      };
    }
  }

  Map<String, dynamic> _manejarError(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      return e.response?.data as Map<String, dynamic>;
    }

    return {
      'success': false,
      'message': e.message ?? 'Error de conexión con el servidor',
    };
  }
}