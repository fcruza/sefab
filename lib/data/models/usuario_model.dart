class UsuarioModel {
  final int id;
  final int rolId;
  final String usuario;
  final String nombres;
  final String apellidos;
  final String correo;
  final int estado;
  final String fechaRegistro;

  UsuarioModel({
    required this.id,
    required this.rolId,
    required this.usuario,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.estado,
    required this.fechaRegistro,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      rolId: int.tryParse(json['rol_id']?.toString() ?? '0') ?? 0,
      usuario: json['usuario']?.toString() ?? '',
      nombres: json['nombres']?.toString() ?? '',
      apellidos: json['apellidos']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      estado: int.tryParse(json['estado']?.toString() ?? '0') ?? 0,
      fechaRegistro: json['fecha_registro']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson({String password = ''}) {
    return {
      'id': id,
      'rol_id': rolId,
      'usuario': usuario,
      'password': password,
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'estado': estado,
    };
  }

  bool get activo => estado == 1;
}