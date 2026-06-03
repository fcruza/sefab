import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/config/app_config.dart';
import '../../data/models/mantenimiento_model.dart';

class MantenimientoService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': AppConfig.apiKey,
      },
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Map<String, dynamic> _parseResponse(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData;
    }
  
    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }
  
    if (responseData is String) {
      final decoded = jsonDecode(responseData);
  
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
  
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }
  
    throw Exception('Respuesta inválida del servidor');
  }

  Future<List<MantenimientoProgramado>> listarCronograma({
    required int mes,
    required int anio,
  }) async {
    final response = await _dio.get(
      '/listar_cronograma.php',
      queryParameters: {
        'mes': mes,
        'anio': anio,
      },
    );

    final data = _parseResponse(response.data);

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'No se pudo listar el cronograma');
    }

    final List items = data['data'] ?? [];

    return items
        .map(
          (e) => MantenimientoProgramado.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  Future<void> eliminarEvidencia({
    required int evidenciaId,
  }) async {
    final response = await _dio.post(
      '/eliminar_evidencia.php',
      data: {
        'evidencia_id': evidenciaId,
      },
    );
  
    final data = _parseResponse(response.data);
  
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'No se pudo eliminar la evidencia');
    }
  }

  Future<Map<String, dynamic>> generarPlanificacion({
    required int cantidadMeses,
    int? mesInicio,
    int? anioInicio,
    String responsable = 'SEFAB',
    String tipo = 'Preventivo',
  }) async {
    final response = await _dio.post(
      '/generar_planificacion.php',
      data: {
        'cantidad_meses': cantidadMeses,
        if (mesInicio != null && mesInicio > 0) 'mes_inicio': mesInicio,
        if (anioInicio != null && anioInicio > 0) 'anio_inicio': anioInicio,
        'responsable': responsable,
        'tipo': tipo,
      },
    );

    final data = _parseResponse(response.data);

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'No se pudo generar la planificación.');
    }

    return data;
  }

  Future<Map<String, dynamic>> moverMantenimientoMes({
    required int id,
    required int mes,
    required int anio,
    required String fechaProgramada,
  }) async {
    final response = await _dio.post(
      '/mover_mantenimiento_mes.php',
      data: {
        'id': id,
        'mes': mes,
        'anio': anio,
        'fecha_programada': fechaProgramada,
      },
    );

    final data = _parseResponse(response.data);

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'No se pudo mover el mantenimiento.',
      );
    }

    return data;
  }

  Future<Map<String, dynamic>> generarPlanificacionEquipo({
    required String equipoCodigo,
    required int cantidadMeses,
    required int mesInicio,
    required int anioInicio,
    String responsable = 'SEFAB',
    String tipo = 'Preventivo',
    String fase = 'Completo',
  }) async {
    final response = await _dio.post(
      '/generar_planificacion_equipo.php',
      data: {
        'equipo_codigo': equipoCodigo,
        'cantidad_meses': cantidadMeses,
        'mes_inicio': mesInicio,
        'anio_inicio': anioInicio,
        'responsable': responsable,
        'tipo': tipo,
        'fase': fase,
      },
    );
  
    final data = _parseResponse(response.data);
  
    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'No se pudo generar la planificación del equipo.',
      );
    }
  
    return data;
  }

  Future<Map<String, dynamic>> actualizarMantenimientoProgramado({
    required int id,
    required String fechaProgramada,
    required String tipo,
    required String fase,
    required String responsable,
    required String estado,
    required String observacion,
  }) async {
    final response = await _dio.post(
      '/actualizar_mantenimiento_programado.php',
      data: {
        'id': id,
        'fecha_programada': fechaProgramada,
        'tipo': tipo,
        'fase': fase,
        'responsable': responsable,
        'estado': estado,
        'observacion': observacion,
      },
    );

    final data = _parseResponse(response.data);

    if (data['success'] != true) {
      throw Exception(
        data['message'] ?? 'No se pudo actualizar el mantenimiento.',
      );
    }

    return data;
  }

  Future<Map<String, dynamic>> guardarEjecucion({
    required int mantenimientoId,
    required String presionRefrigerante,
    required String amperajeCompresor,
    required String observacionTecnica,
    required String recomendacionCorrectiva,
    required String estadoResultado,
    required String usuarioRegistro,
    required List<Map<String, dynamic>> checklist,
  }) async {
    final response = await _dio.post(
      '/guardar_ejecucion.php',
      data: {
        'mantenimiento_id': mantenimientoId,
        'presion_refrigerante': presionRefrigerante,
        'amperaje_compresor': amperajeCompresor,
        'observacion_tecnica': observacionTecnica,
        'recomendacion_correctiva': recomendacionCorrectiva,
        'estado_resultado': estadoResultado,
        'usuario_registro': usuarioRegistro,
        'checklist': checklist,
      },
    );

    final data = _parseResponse(response.data);

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'No se pudo guardar el cumplimiento');
    }

    return data;
  }

  Future<Map<String, dynamic>> listarEjecucion({
    required int mantenimientoId,
  }) async {
    final response = await _dio.get(
      '/listar_ejecucion.php',
      queryParameters: {
        'mantenimiento_id': mantenimientoId,
      },
    );

    final data = _parseResponse(response.data);

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'No se pudo listar la ejecución');
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> listarEvidencias({
    required int mantenimientoId,
  }) async {
    final response = await _dio.get(
      '/listar_evidencias.php',
      queryParameters: {
        'mantenimiento_id': mantenimientoId,
      },
    );

    final data = _parseResponse(response.data);

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'No se pudo listar evidencias');
    }

    final List items = data['data'] ?? [];

    return items.map((e) => Map<String, dynamic>.from(e)).toList();
  }
  
  Future<Map<String, dynamic>> subirEvidencia({
    required int mantenimientoId,
    required int ejecucionId,
    required XFile foto,
    String tipoEvidencia = 'foto',
    String observacion = '',
  }) async {
    final formData = FormData.fromMap({
      'mantenimiento_id': mantenimientoId,
      'ejecucion_id': ejecucionId,
      'tipo_evidencia': tipoEvidencia,
      'observacion': observacion,
      'foto': await MultipartFile.fromFile(
        foto.path,
        filename: foto.name,
      ),
    });

    final response = await _dio.post(
      '/subir_evidencia.php',
      data: formData,
      options: Options(
        headers: {
          'X-API-KEY': AppConfig.apiKey,
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    final data = _parseResponse(response.data);

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'No se pudo subir la evidencia');
    }

    return data;
  }
}