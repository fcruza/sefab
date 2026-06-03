class InstalacionModel {
  final int id;
  final int aireId;
  final int mantenimientoId;

  final String codigoEquipo;
  final String marca;
  final String modelo;
  final String numeroSerie;
  final String capacidadBtu;
  final String voltaje;
  final String tipoEquipo;

  final String area;
  final String ubicacion;
  final String fechaInstalacion;
  final String horaInicio;
  final String horaFin;

  final String responsableTecnico;
  final String responsableArea;

  final bool pruebaEncendido;
  final bool pruebaEnfriamiento;
  final bool drenajeVerificado;
  final bool conexionesElectricasVerificadas;
  final bool fijacionEquipoVerificada;
  final bool tuberiasAisladas;
  final bool limpiezaArea;

  final String estadoResultado;
  final String observacionTecnica;
  final String recomendacion;

  final bool conformidadResponsable;
  final String nombreResponsableConformidad;
  final String usuarioRegistro;
  final String fechaRegistro;

  InstalacionModel({
    required this.id,
    required this.aireId,
    required this.mantenimientoId,
    required this.codigoEquipo,
    required this.marca,
    required this.modelo,
    required this.numeroSerie,
    required this.capacidadBtu,
    required this.voltaje,
    required this.tipoEquipo,
    required this.area,
    required this.ubicacion,
    required this.fechaInstalacion,
    required this.horaInicio,
    required this.horaFin,
    required this.responsableTecnico,
    required this.responsableArea,
    required this.pruebaEncendido,
    required this.pruebaEnfriamiento,
    required this.drenajeVerificado,
    required this.conexionesElectricasVerificadas,
    required this.fijacionEquipoVerificada,
    required this.tuberiasAisladas,
    required this.limpiezaArea,
    required this.estadoResultado,
    required this.observacionTecnica,
    required this.recomendacion,
    required this.conformidadResponsable,
    required this.nombreResponsableConformidad,
    required this.usuarioRegistro,
    required this.fechaRegistro,
  });

  factory InstalacionModel.fromJson(Map<String, dynamic> json) {
    bool toBool(dynamic value) {
      return int.tryParse(value?.toString() ?? '0') == 1;
    }

    return InstalacionModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      aireId: int.tryParse(json['aire_id']?.toString() ?? '0') ?? 0,
      mantenimientoId:
          int.tryParse(json['mantenimiento_id']?.toString() ?? '0') ?? 0,

      codigoEquipo: json['codigo_equipo']?.toString() ?? '',
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      numeroSerie: json['numero_serie']?.toString() ?? '',
      capacidadBtu: json['capacidad_btu']?.toString() ?? '',
      voltaje: json['voltaje']?.toString() ?? '',
      tipoEquipo: json['tipo_equipo']?.toString() ?? '',

      area: json['area']?.toString() ?? '',
      ubicacion: json['ubicacion']?.toString() ?? '',
      fechaInstalacion: json['fecha_instalacion']?.toString() ?? '',
      horaInicio: json['hora_inicio']?.toString() ?? '',
      horaFin: json['hora_fin']?.toString() ?? '',

      responsableTecnico: json['responsable_tecnico']?.toString() ?? '',
      responsableArea: json['responsable_area']?.toString() ?? '',

      pruebaEncendido: toBool(json['prueba_encendido']),
      pruebaEnfriamiento: toBool(json['prueba_enfriamiento']),
      drenajeVerificado: toBool(json['drenaje_verificado']),
      conexionesElectricasVerificadas:
          toBool(json['conexiones_electricas_verificadas']),
      fijacionEquipoVerificada: toBool(json['fijacion_equipo_verificada']),
      tuberiasAisladas: toBool(json['tuberias_aisladas']),
      limpiezaArea: toBool(json['limpieza_area']),

      estadoResultado: json['estado_resultado']?.toString() ?? 'CONFORME',
      observacionTecnica: json['observacion_tecnica']?.toString() ?? '',
      recomendacion: json['recomendacion']?.toString() ?? '',

      conformidadResponsable: toBool(json['conformidad_responsable']),
      nombreResponsableConformidad:
          json['nombre_responsable_conformidad']?.toString() ?? '',
      usuarioRegistro: json['usuario_registro']?.toString() ?? '',
      fechaRegistro: json['fecha_registro']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aire_id': aireId,
      'mantenimiento_id': mantenimientoId,
      'codigo_equipo': codigoEquipo,
      'marca': marca,
      'modelo': modelo,
      'numero_serie': numeroSerie,
      'capacidad_btu': capacidadBtu,
      'voltaje': voltaje,
      'tipo_equipo': tipoEquipo,
      'area': area,
      'ubicacion': ubicacion,
      'fecha_instalacion': fechaInstalacion,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'responsable_tecnico': responsableTecnico,
      'responsable_area': responsableArea,
      'prueba_encendido': pruebaEncendido ? 1 : 0,
      'prueba_enfriamiento': pruebaEnfriamiento ? 1 : 0,
      'drenaje_verificado': drenajeVerificado ? 1 : 0,
      'conexiones_electricas_verificadas':
          conexionesElectricasVerificadas ? 1 : 0,
      'fijacion_equipo_verificada': fijacionEquipoVerificada ? 1 : 0,
      'tuberias_aisladas': tuberiasAisladas ? 1 : 0,
      'limpieza_area': limpiezaArea ? 1 : 0,
      'estado_resultado': estadoResultado,
      'observacion_tecnica': observacionTecnica,
      'recomendacion': recomendacion,
      'conformidad_responsable': conformidadResponsable ? 1 : 0,
      'nombre_responsable_conformidad': nombreResponsableConformidad,
      'usuario_registro': usuarioRegistro,
    };
  }

  factory InstalacionModel.empty() {
    return InstalacionModel(
      id: 0,
      aireId: 0,
      mantenimientoId: 0,
      codigoEquipo: '',
      marca: '',
      modelo: '',
      numeroSerie: '',
      capacidadBtu: '',
      voltaje: '',
      tipoEquipo: '',
      area: '',
      ubicacion: '',
      fechaInstalacion: '',
      horaInicio: '',
      horaFin: '',
      responsableTecnico: '',
      responsableArea: '',
      pruebaEncendido: false,
      pruebaEnfriamiento: false,
      drenajeVerificado: false,
      conexionesElectricasVerificadas: false,
      fijacionEquipoVerificada: false,
      tuberiasAisladas: false,
      limpiezaArea: false,
      estadoResultado: 'CONFORME',
      observacionTecnica: '',
      recomendacion: '',
      conformidadResponsable: false,
      nombreResponsableConformidad: '',
      usuarioRegistro: 'admin',
      fechaRegistro: '',
    );
  }
}