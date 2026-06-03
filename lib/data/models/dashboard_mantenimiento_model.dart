class DashboardMantenimientoModel {
  final int mes;
  final int anio;

  final int totalProgramados;
  final int realizados;
  final int observados;
  final int pendientes;
  final int enProceso;
  final int vencidos;

  final double porcentajeCumplimiento;

  final int totalIncidentes;
  final int totalEvidencias;
  final int petsPendientes;
  final int eppPendientes;

  final List<Map<String, dynamic>> observadosLista;
  final List<Map<String, dynamic>> incidentesLista;

  DashboardMantenimientoModel({
    required this.mes,
    required this.anio,
    required this.totalProgramados,
    required this.realizados,
    required this.observados,
    required this.pendientes,
    required this.enProceso,
    required this.vencidos,
    required this.porcentajeCumplimiento,
    required this.totalIncidentes,
    required this.totalEvidencias,
    required this.petsPendientes,
    required this.eppPendientes,
    required this.observadosLista,
    required this.incidentesLista,
  });

  factory DashboardMantenimientoModel.fromJson(Map<String, dynamic> json) {
    return DashboardMantenimientoModel(
      mes: int.tryParse(json['mes'].toString()) ?? 0,
      anio: int.tryParse(json['anio'].toString()) ?? 0,

      totalProgramados:
          int.tryParse(json['total_programados'].toString()) ?? 0,
      realizados: int.tryParse(json['realizados'].toString()) ?? 0,
      observados: int.tryParse(json['observados'].toString()) ?? 0,
      pendientes: int.tryParse(json['pendientes'].toString()) ?? 0,
      enProceso: int.tryParse(json['en_proceso'].toString()) ?? 0,
      vencidos: int.tryParse(json['vencidos'].toString()) ?? 0,

      porcentajeCumplimiento: double.tryParse(
            json['porcentaje_cumplimiento'].toString(),
          ) ??
          0,

      totalIncidentes:
          int.tryParse(json['total_incidentes'].toString()) ?? 0,
      totalEvidencias:
          int.tryParse(json['total_evidencias'].toString()) ?? 0,
      petsPendientes:
          int.tryParse(json['pets_pendientes'].toString()) ?? 0,
      eppPendientes:
          int.tryParse(json['epp_pendientes'].toString()) ?? 0,

      observadosLista: List<Map<String, dynamic>>.from(
        json['observados_lista'] ?? [],
      ),
      incidentesLista: List<Map<String, dynamic>>.from(
        json['incidentes_lista'] ?? [],
      ),
    );
  }
}