import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../../data/models/instalacion_model.dart';
import 'package:image_picker/image_picker.dart';


class InstalacionService {
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

  Future<Map<String, dynamic>> guardarInstalacion(
    InstalacionModel instalacion,
  ) async {
    try {
      final response = await _dio.post(
        '/guardar_instalacion.php',
        data: instalacion.toJson(),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data;
      }

      return {
        'success': false,
        'message': 'Respuesta inválida del servidor',
        'raw': data.toString(),
      };
    } on DioException catch (e) {
      return _manejarError(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado al guardar instalación: $e',
      };
    }
  }

  Future<Map<String, dynamic>> subirEvidenciaInstalacion({
    required int instalacionId,
    required XFile foto,
    required String tipoEvidencia,
    String observacion = '',
  }) async {
    try {
      final formData = FormData.fromMap({
        'instalacion_id': instalacionId.toString(),
        'tipo_evidencia': tipoEvidencia,
        'observacion': observacion,
        'foto': await MultipartFile.fromFile(
          foto.path,
          filename: foto.name,
        ),
      });

      final response = await _dio.post(
        '/subir_evidencia_instalacion.php',
        data: formData,
        options: Options(
          headers: {
            'X-API-KEY': AppConfig.apiKey,
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data;
      }

      return {
        'success': false,
        'message': 'Respuesta inválida del servidor',
        'raw': data.toString(),
      };
    } on DioException catch (e) {
      return _manejarError(e);
    } catch (e) {
      return {
        'success': false,
        'message': 'Error inesperado al subir evidencia: $e',
      };
    }
  }

  Future<List<InstalacionModel>> listarInstalaciones({
    int? mes,
    int? anio,
    String? estado,
  }) async {
    try {
      final response = await _dio.get(
        '/listar_instalaciones.php',
        queryParameters: {
          if (mes != null) 'mes': mes,
          if (anio != null) 'anio': anio,
          if (estado != null && estado.trim().isNotEmpty)
            'estado': estado.trim(),
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Respuesta inválida del servidor');
      }

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'No se pudo cargar instalaciones');
      }

      final list = data['data'];

      if (list is! List) {
        return [];
      }

      return list
          .map(
            (e) => InstalacionModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    } on DioException catch (e) {
      final error = _manejarError(e);
      throw Exception(error['message'] ?? 'Error de conexión');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<Map<String, dynamic>>> listarEvidenciasInstalacion({
    required int instalacionId,
  }) async {
    try {
      final response = await _dio.get(
        '/listar_evidencias_instalacion.php',
        queryParameters: {
          'instalacion_id': instalacionId,
        },
      );
  
      final data = response.data;
  
      if (data is! Map<String, dynamic>) {
        throw Exception('Respuesta inválida del servidor');
      }
  
      if (data['success'] != true) {
        throw Exception(
          data['message'] ?? 'No se pudieron cargar las evidencias',
        );
      }
  
      final list = data['data'];
  
      if (list is! List) {
        return [];
      }
  
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } on DioException catch (e) {
      final error = _manejarError(e);
      throw Exception(error['message'] ?? 'Error de conexión');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
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