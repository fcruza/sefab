class PetsChecklistModel {
  final int ejecucionId;

  final bool coordinacionArea;
  final bool ipercRevisado;
  final bool zonaDelimitada;
  final bool accesoRestringido;
  final bool herramientasVerificadas;
  final bool permisoTrabajo;

  final bool lotoAplicado;
  final bool ausenciaTensionVerificada;
  final bool personalAutorizado;

  final bool condicionInsegura;
  final bool actividadSuspendida;

  final String observacion;
  final String usuarioRegistro;

  PetsChecklistModel({
    required this.ejecucionId,
    required this.coordinacionArea,
    required this.ipercRevisado,
    required this.zonaDelimitada,
    required this.accesoRestringido,
    required this.herramientasVerificadas,
    required this.permisoTrabajo,
    required this.lotoAplicado,
    required this.ausenciaTensionVerificada,
    required this.personalAutorizado,
    required this.condicionInsegura,
    required this.actividadSuspendida,
    required this.observacion,
    required this.usuarioRegistro,
  });

  Map<String, dynamic> toJson() {
    return {
      'ejecucion_id': ejecucionId,
      'coordinacion_area': coordinacionArea ? 1 : 0,
      'iperc_revisado': ipercRevisado ? 1 : 0,
      'zona_delimitada': zonaDelimitada ? 1 : 0,
      'acceso_restringido': accesoRestringido ? 1 : 0,
      'herramientas_verificadas': herramientasVerificadas ? 1 : 0,
      'permiso_trabajo': permisoTrabajo ? 1 : 0,
      'loto_aplicado': lotoAplicado ? 1 : 0,
      'ausencia_tension_verificada': ausenciaTensionVerificada ? 1 : 0,
      'personal_autorizado': personalAutorizado ? 1 : 0,
      'condicion_insegura': condicionInsegura ? 1 : 0,
      'actividad_suspendida': actividadSuspendida ? 1 : 0,
      'observacion': observacion,
      'usuario_registro': usuarioRegistro,
    };
  }
}