import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../../data/models/dashboard_mantenimiento_model.dart';

class DashboardService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'X-API-KEY': AppConfig.apiKey,
        'Accept': 'application/json',
      },
    ),
  );

  Future<DashboardMantenimientoModel> obtenerDashboard({
    required int mes,
    required int anio,
  }) async {
    try {
      final response = await _dio.get(
        '/dashboard_mantenimiento.php',
        queryParameters: {
          'mes': mes,
          'anio': anio,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception('Respuesta inválida del servidor.');
      }

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'No se pudo cargar el dashboard.');
      }

      return DashboardMantenimientoModel.fromJson(
        Map<String, dynamic>.from(data['data']),
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        final data = e.response?.data as Map<String, dynamic>;
        throw Exception(data['message'] ?? 'Error del servidor.');
      }

      throw Exception(e.message ?? 'Error de conexión.');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}