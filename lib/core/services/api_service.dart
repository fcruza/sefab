import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class ApiService {
  late final Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'X-API-KEY': AppConstants.apiKey,
          'Accept': 'application/json',
        },
      ),
    );
  }
}
