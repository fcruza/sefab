import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../data/models/mantenimiento_model.dart';

class AiresService {
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

  Future<List<AireEquipo>> listarAires({
    String buscar = '',
  }) async {
    final response = await _dio.get(
      '/listar_aires.php',
      queryParameters: {
        if (buscar.trim().isNotEmpty) 'buscar': buscar.trim(),
      },
    );

    final data = _parseResponse(response.data);

    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'No se pudo listar los equipos.');
    }

    final List items = data['data'] ?? [];

    return items
        .map(
          (item) => AireEquipo.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<AireEquipo> guardarAire({
    required int id,
    required String codigo,
    required String area,
    required String ubicacion,
    required String marca,
    required String modelo,
    required String serie,
    required String capacidadBtu,
    required String tipoEquipo,
    required String frecuenciaMantenimiento,
    required String fechaCompra,
    required String fechaInstalacion,
    required String observacion,
    required int estado,    
  }) async {
    final response = await _dio.post(
      '/guardar_aire.php',
      data: {
        'id': id,
        'codigo': codigo,
        'area': area,
        'ubicacion': ubicacion,
        'marca': marca,
        'modelo': modelo,
        'serie': serie,
        'capacidad_btu': capacidadBtu,
        'tipo_equipo': tipoEquipo,
        'frecuencia_mantenimiento': frecuenciaMantenimiento,
        'fecha_compra': fechaCompra,
        'fecha_instalacion': fechaInstalacion,
        'observacion': observacion,
        'estado': estado,        
      },
    );
  
    final data = _parseResponse(response.data);
  
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'No se pudo guardar el equipo.');
    }
  
    return AireEquipo.fromJson(
      Map<String, dynamic>.from(data['equipo']),
    );
  }

}