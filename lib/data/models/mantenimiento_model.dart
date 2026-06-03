class MantenimientoProgramado {
  final int id;
  final int mes;
  final int anio;
  final String equipoCodigo;
  final String equipoMarca;
  final String area;
  final String ubicacion;
  final String fechaProgramada;
  final String diaTrabajo;
  final String tipo;
  final String fase;
  final String responsable;
  final String estado;
  final int checklistCompletado;
  final int checklistTotal;
  final int fotos;
  final String observacion;

  MantenimientoProgramado({
    required this.id,
    required this.mes,
    required this.anio,
    required this.equipoCodigo,
    required this.equipoMarca,
    required this.area,
    required this.ubicacion,
    required this.fechaProgramada,
    required this.diaTrabajo,
    required this.tipo,
    required this.fase,
    required this.responsable,
    required this.estado,
    required this.checklistCompletado,
    required this.checklistTotal,
    required this.fotos,
    required this.observacion,
  });

  factory MantenimientoProgramado.fromJson(Map<String, dynamic> json) {
    return MantenimientoProgramado(
      id: int.tryParse(json['id'].toString()) ?? 0,
      mes: int.tryParse(json['mes'].toString()) ?? 0,
      anio: int.tryParse(json['anio'].toString()) ?? 2026,
      equipoCodigo: json['equipo_codigo']?.toString() ?? '',
      equipoMarca: json['equipo_marca']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      ubicacion: json['ubicacion']?.toString() ?? '',
      fechaProgramada: json['fecha_programada']?.toString() ?? '',
      diaTrabajo: json['dia_trabajo']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      fase: json['fase']?.toString() ?? '',
      responsable: json['responsable']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'Pendiente',
      checklistCompletado:
          int.tryParse(json['checklist_completado'].toString()) ?? 0,
      checklistTotal: int.tryParse(json['checklist_total'].toString()) ?? 0,
      fotos: int.tryParse(json['fotos'].toString()) ?? 0,
      observacion: json['observacion']?.toString() ?? '',
    );
  }

  MantenimientoProgramado copyWith({
    int? id,
    int? mes,
    int? anio,
    String? equipoCodigo,
    String? equipoMarca,
    String? area,
    String? ubicacion,
    String? fechaProgramada,
    String? diaTrabajo,
    String? tipo,
    String? fase,
    String? responsable,
    String? estado,
    int? checklistCompletado,
    int? checklistTotal,
    int? fotos,
    String? observacion,
  }) {
    return MantenimientoProgramado(
      id: id ?? this.id,
      mes: mes ?? this.mes,
      anio: anio ?? this.anio,
      equipoCodigo: equipoCodigo ?? this.equipoCodigo,
      equipoMarca: equipoMarca ?? this.equipoMarca,
      area: area ?? this.area,
      ubicacion: ubicacion ?? this.ubicacion,
      fechaProgramada: fechaProgramada ?? this.fechaProgramada,
      diaTrabajo: diaTrabajo ?? this.diaTrabajo,
      tipo: tipo ?? this.tipo,
      fase: fase ?? this.fase,
      responsable: responsable ?? this.responsable,
      estado: estado ?? this.estado,
      checklistCompletado: checklistCompletado ?? this.checklistCompletado,
      checklistTotal: checklistTotal ?? this.checklistTotal,
      fotos: fotos ?? this.fotos,
      observacion: observacion ?? this.observacion,
    );
  }
}

class AireEquipo {
  final int id;
  final String codigo;
  final String area;
  final String ubicacion;
  final String marca;
  final String modelo;
  final String serie;
  final String capacidadBtu;
  final String tipoEquipo;
  final String fechaCompra;
  final String fechaInstalacion;
  final String foto;
  final String observacion;
  final int estado;
  final String fechaRegistro;
  final String frecuenciaMantenimiento;

  AireEquipo({
    required this.id,
    required this.codigo,
    required this.area,
    required this.ubicacion,
    required this.marca,
    required this.modelo,
    required this.serie,
    required this.capacidadBtu,
    required this.tipoEquipo,
    required this.fechaCompra,
    required this.fechaInstalacion,
    required this.foto,
    required this.observacion,
    required this.estado,
    required this.fechaRegistro,
    required this.frecuenciaMantenimiento,
  });

  factory AireEquipo.fromJson(Map<String, dynamic> json) {
    return AireEquipo(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      ubicacion: json['ubicacion']?.toString() ?? '',
      marca: json['marca']?.toString() ?? 'No registrado',
      modelo: json['modelo']?.toString() ?? 'No registrado',
      serie: json['serie']?.toString() ?? 'No registrado',
      capacidadBtu: json['capacidad_btu']?.toString() ?? 'No registrado',
      tipoEquipo: json['tipo_equipo']?.toString() ?? 'No registrado',
      fechaCompra: json['fecha_compra']?.toString() ?? '',
      fechaInstalacion: json['fecha_instalacion']?.toString() ?? '',
      foto: json['foto']?.toString() ?? '',
      observacion: json['observacion']?.toString() ?? '',
      estado: int.tryParse(json['estado']?.toString() ?? '1') ?? 1,
      fechaRegistro: json['fecha_registro']?.toString() ?? '',
      frecuenciaMantenimiento: json['frecuencia_mantenimiento']?.toString() ?? 'Trimestral',
    );
  }
}