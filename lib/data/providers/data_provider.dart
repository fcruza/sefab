import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../models/app_models.dart';

class DataProvider extends ChangeNotifier {
  final ApiService api;
  DataProvider(this.api);

  List<AppModule> modulos = [];
  List<AppUser> usuarios = [];
  List<AireModel> aires = [];
  List<MantenimientoModel> mantenimientos = [];
  List<InformeModel> informes = [];

  Future<void> loadModulos() async {
    final r = await api.dio.get('listar_modulos.php');
    final data = Map<String, dynamic>.from(r.data);
    if (data['ok'] != true) throw Exception(data['msg'] ?? 'Error');
    modulos = (data['modulos'] as List).map((e) => AppModule.fromJson(Map<String, dynamic>.from(e))).toList();
    notifyListeners();
  }

  Future<void> loadUsuarios() async {
    final r = await api.dio.get('listar_usuarios.php', queryParameters: {'t': DateTime.now().millisecondsSinceEpoch});
    final data = Map<String, dynamic>.from(r.data);
    if (data['ok'] != true) throw Exception(data['msg'] ?? 'Error');
    usuarios = (data['usuarios'] as List).map((e) => AppUser.fromJson(Map<String, dynamic>.from(e))).toList();
    notifyListeners();
  }

  Future<void> saveUsuario(Map<String, dynamic> values) async { await api.dio.post('guardar_usuario.php', data: values); await loadUsuarios(); }
  Future<void> cambiarEstadoUsuario(int id, bool activo) async { await api.dio.post('estado_usuario.php', data: {'id': id, 'estado': activo ? 1 : 0}); await loadUsuarios(); }
  Future<void> guardarUsuarioModulo(int usuarioId, int moduloId, bool asignado) async { await api.dio.post('guardar_usuario_modulo.php', data: {'usuario_id': usuarioId, 'modulo_id': moduloId, 'asignado': asignado ? 1 : 0}); await loadUsuarios(); }

  Future<void> loadAires() async {
    final r = await api.dio.get('listar_aires.php', queryParameters: {'t': DateTime.now().millisecondsSinceEpoch});
    final data = Map<String, dynamic>.from(r.data);
    if (data['ok'] != true) throw Exception(data['msg'] ?? 'Error');
    aires = (data['aires'] as List).map((e) => AireModel.fromJson(Map<String, dynamic>.from(e))).toList();
    notifyListeners();
  }
  Future<void> saveAire(Map<String, dynamic> values, {File? foto}) async {
    final form = FormData.fromMap(values);
    if (foto != null) form.files.add(MapEntry('foto', await MultipartFile.fromFile(foto.path)));
    await api.dio.post('guardar_aire.php', data: form);
    await loadAires();
  }
  Future<void> eliminarAire(int id) async { await api.dio.post('eliminar_aire.php', data: {'id': id}); await loadAires(); }

  Future<void> loadMantenimientos() async {
    final r = await api.dio.get('listar_mantenimientos.php');
    final data = Map<String, dynamic>.from(r.data);
    if (data['ok'] != true) throw Exception(data['msg'] ?? 'Error');
    mantenimientos = (data['mantenimientos'] as List).map((e) => MantenimientoModel.fromJson(Map<String, dynamic>.from(e))).toList();
    notifyListeners();
  }
  Future<void> saveMantenimiento(Map<String, dynamic> values) async { await api.dio.post('guardar_mantenimiento.php', data: values); await loadMantenimientos(); }

  Future<void> loadInformes() async {
    final r = await api.dio.get('listar_informes.php');
    final data = Map<String, dynamic>.from(r.data);
    if (data['ok'] != true) throw Exception(data['msg'] ?? 'Error');
    informes = (data['informes'] as List).map((e) => InformeModel.fromJson(Map<String, dynamic>.from(e))).toList();
    notifyListeners();
  }
  Future<InformeModel> generarInforme(Map<String, dynamic> values) async {
    final r = await api.dio.post('generar_informe_pdf.php', data: values);
    final data = Map<String, dynamic>.from(r.data);
    if (data['ok'] != true) throw Exception(data['msg'] ?? 'Error');
    await loadInformes();
    return InformeModel.fromJson(Map<String, dynamic>.from(data['informe']));
  }
  Future<void> enviarInforme(int id, String correo) async { await api.dio.post('enviar_informe_correo.php', data: {'id': id, 'correo': correo}); }
}
