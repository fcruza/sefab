class ModuloModel {
  final int id;
  final String nombre;
  final String ruta;
  final String icono;
  final int orden;
  final int estado;

  ModuloModel({
    required this.id,
    required this.nombre,
    required this.ruta,
    required this.icono,
    required this.orden,
    required this.estado,
  });

  factory ModuloModel.fromJson(Map<String, dynamic> json) {
    return ModuloModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      ruta: json['ruta']?.toString() ?? '',
      icono: json['icono']?.toString() ?? '',
      orden: int.tryParse(json['orden']?.toString() ?? '0') ?? 0,
      estado: int.tryParse(json['estado']?.toString() ?? '0') ?? 0,
    );
  }
}