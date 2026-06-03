class AppUser {
  final int id;
  final String usuario;
  final String nombres;
  final String apellidos;
  final String rol;
  final bool activo;
  final List<String> modulos;
  AppUser({required this.id, required this.usuario, required this.nombres, required this.apellidos, required this.rol, required this.activo, required this.modulos});
  String get nombreCompleto => '$nombres $apellidos'.trim();
  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: int.tryParse('${j['id']}') ?? 0,
    usuario: j['usuario']?.toString() ?? '',
    nombres: j['nombres']?.toString() ?? '',
    apellidos: j['apellidos']?.toString() ?? '',
    rol: j['rol']?.toString() ?? '',
    activo: '${j['estado'] ?? 1}' == '1',
    modulos: (j['modulos'] is List) ? (j['modulos'] as List).map((e) => e.toString()).toList() : [],
  );
}

class AppModule {
  final int id;
  final String nombre;
  final String ruta;
  final String icono;
  AppModule({required this.id, required this.nombre, required this.ruta, required this.icono});
  factory AppModule.fromJson(Map<String, dynamic> j) => AppModule(id: int.tryParse('${j['id']}') ?? 0, nombre: j['nombre']?.toString() ?? '', ruta: j['ruta']?.toString() ?? '', icono: j['icono']?.toString() ?? 'dashboard');
}

class AireModel {
  final int id;
  final String codigo;
  final String area;
  final String ubicacion;
  final String marca;
  final String modelo;
  final String serie;
  final String capacidadBtu;
  final String tipo;
  final String fechaCompra;
  final String fechaInstalacion;
  final String estadoOperativo;
  final String fotoUrl;
  final bool activo;
  AireModel({required this.id, required this.codigo, required this.area, required this.ubicacion, required this.marca, required this.modelo, required this.serie, required this.capacidadBtu, required this.tipo, required this.fechaCompra, required this.fechaInstalacion, required this.estadoOperativo, required this.fotoUrl, required this.activo});
  factory AireModel.fromJson(Map<String, dynamic> j) => AireModel(
    id: int.tryParse('${j['id']}') ?? 0,
    codigo: j['codigo']?.toString() ?? '', area: j['area']?.toString() ?? '', ubicacion: j['ubicacion']?.toString() ?? '', marca: j['marca']?.toString() ?? '', modelo: j['modelo']?.toString() ?? '', serie: j['serie']?.toString() ?? '', capacidadBtu: j['capacidad_btu']?.toString() ?? '', tipo: j['tipo']?.toString() ?? '', fechaCompra: j['fecha_compra']?.toString() ?? '', fechaInstalacion: j['fecha_instalacion']?.toString() ?? '', estadoOperativo: j['estado_operativo']?.toString() ?? 'Operativo', fotoUrl: j['foto_url']?.toString() ?? '', activo: '${j['estado'] ?? 1}' == '1');
}

class MantenimientoModel {
  final int id;
  final String fechaProgramada;
  final String cliente;
  final String area;
  final String estadoMantenimiento;
  final String observacion;
  MantenimientoModel({required this.id, required this.fechaProgramada, required this.cliente, required this.area, required this.estadoMantenimiento, required this.observacion});
  factory MantenimientoModel.fromJson(Map<String, dynamic> j) => MantenimientoModel(id: int.tryParse('${j['id']}') ?? 0, fechaProgramada: j['fecha_programada']?.toString() ?? '', cliente: j['cliente']?.toString() ?? '', area: j['area']?.toString() ?? '', estadoMantenimiento: j['estado_mantenimiento']?.toString() ?? 'Programado', observacion: j['observacion']?.toString() ?? '');
}

class InformeModel {
  final int id;
  final String numero;
  final String cliente;
  final String fecha;
  final String asunto;
  final String pdfUrl;
  InformeModel({required this.id, required this.numero, required this.cliente, required this.fecha, required this.asunto, required this.pdfUrl});
  factory InformeModel.fromJson(Map<String, dynamic> j) => InformeModel(id: int.tryParse('${j['id']}') ?? 0, numero: j['numero_informe']?.toString() ?? '', cliente: j['cliente_nombre']?.toString() ?? '', fecha: j['fecha_informe']?.toString() ?? '', asunto: j['asunto']?.toString() ?? '', pdfUrl: j['pdf_url']?.toString() ?? '');
}
