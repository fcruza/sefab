import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../../data/models/pets_checklist_model.dart';
import '../../data/models/epp_checklist_model.dart';
import '../../data/models/incidente_model.dart';

class SeguridadService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'X-API-KEY': AppConfig.apiKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<Map<String, dynamic>> listarIncidente({
    required int ejecucionId,
  }) async {
    try {
      final response = await _dio.get(
        '/listar_incidentes.php',
        queryParameters: {
          'ejecucion_id': ejecucionId,
        },
      );
  
      return _procesarRespuesta(response);
    } on DioException catch (e) {
      return _manejarErrorDio(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado al listar incidente: $e',
      };
    }
  }

  Future<Map<String, dynamic>> guardarPetsChecklist(
    PetsChecklistModel data,
  ) async {
    try {
      final response = await _dio.post(
        '/guardar_pets_checklist.php',
        data: data.toJson(),
      );

      return _procesarRespuesta(response);
    } on DioException catch (e) {
      return _manejarErrorDio(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado al guardar checklist PETS: $e',
      };
    }
  }

  Future<Map<String, dynamic>> guardarEppChecklist(
    EppChecklistModel data,
  ) async {
    try {
      final response = await _dio.post(
        '/guardar_epp_checklist.php',
        data: data.toJson(),
      );

      return _procesarRespuesta(response);
    } on DioException catch (e) {
      return _manejarErrorDio(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado al guardar checklist EPP: $e',
      };
    }
  }

  Future<Map<String, dynamic>> listarPetsChecklist({
    required int ejecucionId,
  }) async {
    try {
      final response = await _dio.get(
        '/listar_pets_checklist.php',
        queryParameters: {
          'ejecucion_id': ejecucionId,
        },
      );

      return _procesarRespuesta(response);
    } on DioException catch (e) {
      return _manejarErrorDio(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado al listar checklist PETS: $e',
      };
    }
  }

  Future<Map<String, dynamic>> listarEppChecklist({
    required int ejecucionId,
  }) async {
    try {
      final response = await _dio.get(
        '/listar_epp_checklist.php',
        queryParameters: {
          'ejecucion_id': ejecucionId,
        },
      );

      return _procesarRespuesta(response);
    } on DioException catch (e) {
      return _manejarErrorDio(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado al listar checklist EPP: $e',
      };
    }
  }

  Future<Map<String, dynamic>> guardarIncidente(
    IncidenteModel data,
  ) async {
    try {
      final response = await _dio.post(
        '/guardar_incidente.php',
        data: data.toJson(),
      );

      return _procesarRespuesta(response);
    } on DioException catch (e) {
      return _manejarErrorDio(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado al guardar incidente: $e',
      };
    }
  }

  Map<String, dynamic> _procesarRespuesta(Response response) {
    if (response.data is Map<String, dynamic>) {
      return response.data;
    }

    return {
      'success': false,
      'message': 'Respuesta inválida del servidor',
      'raw': response.data.toString(),
    };
  }

  Map<String, dynamic> _manejarErrorDio(DioException e) {
    if (e.response != null && e.response?.data is Map<String, dynamic>) {
      return e.response?.data as Map<String, dynamic>;
    }

    return {
      'success': false,
      'message': e.message ?? 'Error de conexión con el servidor',
    };
  }
}