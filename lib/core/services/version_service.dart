import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../constants/app_constants.dart';

class VersionCheckResult {
  final bool ok;
  final bool requiereActualizacion;
  final bool obligatorio;
  final String mensaje;
  final String versionApp;
  final String versionMinima;
  final String versionActual;
  final String urlActualizacion;

  VersionCheckResult({required this.ok, required this.requiereActualizacion, required this.obligatorio, required this.mensaje, required this.versionApp, required this.versionMinima, required this.versionActual, required this.urlActualizacion});

  factory VersionCheckResult.fromJson(Map<String, dynamic> json) {
    return VersionCheckResult(
      ok: json['ok'] == true,
      requiereActualizacion: json['requiere_actualizacion'] == true,
      obligatorio: json['obligatorio'] == true,
      mensaje: json['msg']?.toString() ?? '',
      versionApp: json['version_app']?.toString() ?? '',
      versionMinima: json['version_minima']?.toString() ?? '',
      versionActual: json['version_actual']?.toString() ?? '',
      urlActualizacion: json['url_actualizacion']?.toString() ?? '',
    );
  }
}

class VersionService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    headers: {'X-API-KEY': AppConstants.apiKey, 'Accept': 'application/json'},
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 12),
  ));

  Future<String> versionVisible() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  Future<VersionCheckResult> verificarVersion() async {
    final info = await PackageInfo.fromPlatform();
    final versionApp = info.version;
    final buildNumber = info.buildNumber;
    final plataforma = Platform.isIOS ? 'ios' : 'android';
    debugPrint('VERSION APP ENVIADA: $versionApp+$buildNumber / $plataforma');
    final response = await _dio.post('verificar_version_app.php', data: {'version_app': versionApp, 'build_number': buildNumber, 'plataforma': plataforma});
    return VersionCheckResult.fromJson(Map<String, dynamic>.from(response.data));
  }
}
