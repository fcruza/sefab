class RolModel {
  final int id;
  final String nombre;
  final int estado;

  RolModel({
    required this.id,
    required this.nombre,
    required this.estado,
  });

  factory RolModel.fromJson(Map<String, dynamic> json) {
    return RolModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      estado: int.tryParse(json['estado']?.toString() ?? '0') ?? 0,
    );
  }
}