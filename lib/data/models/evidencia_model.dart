class EvidenciaMantenimiento {
  final int id;
  final int mantenimientoId;
  final int ejecucionId;
  final String archivo;
  final String url;
  final String tipoEvidencia;
  final String observacion;
  final String fechaRegistro;

  EvidenciaMantenimiento({
    required this.id,
    required this.mantenimientoId,
    required this.ejecucionId,
    required this.archivo,
    required this.url,
    required this.tipoEvidencia,
    required this.observacion,
    required this.fechaRegistro,
  });

  factory EvidenciaMantenimiento.fromJson(Map<String, dynamic> json) {
    return EvidenciaMantenimiento(
      id: int.tryParse(json['id'].toString()) ?? 0,
      mantenimientoId: int.tryParse(json['mantenimiento_id'].toString()) ?? 0,
      ejecucionId: int.tryParse(json['ejecucion_id'].toString()) ?? 0,
      archivo: json['archivo']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      tipoEvidencia: json['tipo_evidencia']?.toString() ?? '',
      observacion: json['observacion']?.toString() ?? '',
      fechaRegistro: json['fecha_registro']?.toString() ?? '',
    );
  }
}