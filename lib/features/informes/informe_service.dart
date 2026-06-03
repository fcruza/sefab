import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';

class InformeService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': AppConfig.apiKey,
      },
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Map<String, dynamic> _parseResponse(dynamic responseData) {
    if (responseData == null) {
      throw Exception('El servidor respondió vacío.');
    }

    if (responseData is Map<String, dynamic>) {
      return responseData;
    }

    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }

    if (responseData is String) {
      final texto = responseData.trim();

      if (texto.isEmpty) {
        throw Exception('El servidor respondió vacío.');
      }

      if (texto.startsWith('<')) {
        throw Exception('El servidor respondió HTML en vez de JSON.');
      }

      final decoded = jsonDecode(texto);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    throw Exception('Respuesta inválida del servidor.');
  }

  Future<Map<String, dynamic>> obtenerReporteMensual({
    required int mes,
    required int anio,
  }) async {
    final response = await _dio.get(
      '/reporte_mantenimiento_mensual.php',
      queryParameters: {
        'mes': mes,
        'anio': anio,
      },
    );

    final data = _parseResponse(response.data);

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'No se pudo generar el reporte.');
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> listarInformes({
    int? mes,
    int? anio,
    String buscar = '',
  }) async {
    final response = await _dio.get(
      '/listar_informes.php',
      queryParameters: {
        if (mes != null && mes > 0) 'mes': mes,
        if (anio != null && anio > 0) 'anio': anio,
        if (buscar.trim().isNotEmpty) 'buscar': buscar.trim(),
      },
    );

    final data = _parseResponse(response.data);

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'No se pudo listar los informes.');
    }

    final List items = data['data'] ?? [];

    return items
        .map(
          (e) => Map<String, dynamic>.from(e),
        )
        .toList();
  }

  Future<Map<String, dynamic>> listarHistorialMediciones({
    required String equipoCodigo,
  }) async {
    final response = await _dio.get(
      '/listar_historial_mediciones.php',
      queryParameters: {
        'equipo_codigo': equipoCodigo,
      },
    );
  
    final data = _parseResponse(response.data);
  
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'No se pudo listar el historial técnico.');
    }
  
    return data;
  }
}