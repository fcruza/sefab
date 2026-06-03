class EppChecklistModel {
  final int ejecucionId;

  final bool casco;
  final bool lentes;
  final bool guantesTrabajo;
  final bool guantesDielectricos;
  final bool zapatosSeguridad;
  final bool mascarilla;
  final bool arnes;
  final bool proteccionAuditiva;
  final bool ropaMangaLarga;

  final String observacion;
  final String usuarioRegistro;

  EppChecklistModel({
    required this.ejecucionId,
    required this.casco,
    required this.lentes,
    required this.guantesTrabajo,
    required this.guantesDielectricos,
    required this.zapatosSeguridad,
    required this.mascarilla,
    required this.arnes,
    required this.proteccionAuditiva,
    required this.ropaMangaLarga,
    required this.observacion,
    required this.usuarioRegistro,
  });

  Map<String, dynamic> toJson() {
    return {
      'ejecucion_id': ejecucionId,
      'casco': casco ? 1 : 0,
      'lentes': lentes ? 1 : 0,
      'guantes_trabajo': guantesTrabajo ? 1 : 0,
      'guantes_dielectricos': guantesDielectricos ? 1 : 0,
      'zapatos_seguridad': zapatosSeguridad ? 1 : 0,
      'mascarilla': mascarilla ? 1 : 0,
      'arnes': arnes ? 1 : 0,
      'proteccion_auditiva': proteccionAuditiva ? 1 : 0,
      'ropa_manga_larga': ropaMangaLarga ? 1 : 0,
      'observacion': observacion,
      'usuario_registro': usuarioRegistro,
    };
  }
}