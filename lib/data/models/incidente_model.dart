class IncidenteModel {
  final int ejecucionId;
  final String tipoIncidente;
  final String descripcion;
  final String accionTomada;
  final bool actividadSuspendida;
  final String reportadoA;
  final String foto;
  final String usuarioRegistro;

  IncidenteModel({
    required this.ejecucionId,
    required this.tipoIncidente,
    required this.descripcion,
    required this.accionTomada,
    required this.actividadSuspendida,
    required this.reportadoA,
    required this.foto,
    required this.usuarioRegistro,
  });

  Map<String, dynamic> toJson() {
    return {
      'ejecucion_id': ejecucionId,
      'tipo_incidente': tipoIncidente,
      'descripcion': descripcion,
      'accion_tomada': accionTomada,
      'actividad_suspendida': actividadSuspendida ? 1 : 0,
      'reportado_a': reportadoA,
      'foto': foto,
      'usuario_registro': usuarioRegistro,
    };
  }
}