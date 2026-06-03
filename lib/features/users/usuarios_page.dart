import 'package:flutter/material.dart';

import '../../core/services/usuario_service.dart';
import '../../data/models/modulo_model.dart';
import '../../data/models/rol_model.dart';
import '../../data/models/usuario_model.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final UsuarioService _usuarioService = UsuarioService();

  bool cargando = false;
  String? error;

  List<UsuarioModel> usuarios = [];
  List<RolModel> roles = [];
  List<ModuloModel> modulos = [];

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  Future<void> _cargarTodo() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final dataUsuarios = await _usuarioService.listarUsuarios();
      final dataRoles = await _usuarioService.listarRoles();
      final dataModulos = await _usuarioService.listarModulos();

      if (!mounted) return;

      setState(() {
        usuarios = dataUsuarios;
        roles = dataRoles;
        modulos = dataModulos;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  String _nombreRol(int rolId) {
    final rol = roles.where((r) => r.id == rolId).toList();

    if (rol.isEmpty) return 'Sin rol';

    return rol.first.nombre;
  }

  Future<void> _abrirFormulario({UsuarioModel? usuario}) async {
    if (roles.isEmpty) {
      _mensaje('Primero debe existir al menos un rol activo.', error: true);
      return;
    }

    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _UsuarioFormSheet(
          usuarioService: _usuarioService,
          usuario: usuario,
          roles: roles,
          modulos: modulos,
        );
      },
    );

    if (resultado == true) {
      await _cargarTodo();
    }
  }

  Future<void> _cambiarEstado(UsuarioModel usuario) async {
    final nuevoEstado = usuario.activo ? 0 : 1;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(usuario.activo ? 'Desactivar usuario' : 'Activar usuario'),
        content: Text(
          usuario.activo
              ? '¿Desea desactivar a ${usuario.nombres}?'
              : '¿Desea activar a ${usuario.nombres}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final resp = await _usuarioService.cambiarEstadoUsuario(
      usuarioId: usuario.id,
      estado: nuevoEstado,
    );

    final success = resp['success'] == true;

    _mensaje(
      resp['message']?.toString() ??
          (success ? 'Estado actualizado.' : 'No se pudo actualizar.'),
      error: !success,
    );

    if (success) {
      await _cargarTodo();
    }
  }

  void _mensaje(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Widget _usuarioCard(UsuarioModel usuario) {
    final activo = usuario.activo;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _abrirFormulario(usuario: usuario),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: activo
                    ? const Color(0xFFEFF6FF)
                    : const Color(0xFFF3F4F6),
                child: Icon(
                  Icons.person_outline,
                  color: activo
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF6B7280),
                  size: 30,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${usuario.nombres} ${usuario.apellidos}'.trim(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '@${usuario.usuario}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Chip(
                          label: Text(
                            _nombreRol(usuario.rolId),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: const Color(0xFFFFF7ED),
                          side: BorderSide.none,
                        ),
                        Chip(
                          label: Text(
                            activo ? 'Activo' : 'Inactivo',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: activo
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                          backgroundColor: activo
                              ? const Color(0xFFF0FDF4)
                              : const Color(0xFFFEF2F2),
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'editar') {
                    _abrirFormulario(usuario: usuario);
                  }

                  if (value == 'estado') {
                    _cambiarEstado(usuario);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'editar',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'estado',
                    child: Row(
                      children: [
                        Icon(
                          activo
                              ? Icons.block_outlined
                              : Icons.check_circle_outline,
                        ),
                        const SizedBox(width: 8),
                        Text(activo ? 'Desactivar' : 'Activar'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contenido() {
    if (cargando) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF97316),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: _cargarTodo,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarTodo,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).padding.bottom + 100,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1F2937),
                  Color(0xFF374151),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.people_alt_outlined,
                    color: Color(0xFFF97316),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${usuarios.length} usuarios registrados',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (usuarios.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 48,
                    color: Colors.black38,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No hay usuarios registrados.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )
          else
            ...usuarios.map(_usuarioCard),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);
    const Color sefAccent = Color(0xFFF97316);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Usuarios'),
        backgroundColor: sefPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: cargando ? null : _cargarTodo,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: sefAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: _contenido(),
    );
  }
}

class _UsuarioFormSheet extends StatefulWidget {
  final UsuarioService usuarioService;
  final UsuarioModel? usuario;
  final List<RolModel> roles;
  final List<ModuloModel> modulos;

  const _UsuarioFormSheet({
    required this.usuarioService,
    required this.usuario,
    required this.roles,
    required this.modulos,
  });

  @override
  State<_UsuarioFormSheet> createState() => _UsuarioFormSheetState();
}

class _UsuarioFormSheetState extends State<_UsuarioFormSheet> {
  final usuarioCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nombresCtrl = TextEditingController();
  final apellidosCtrl = TextEditingController();
  final correoCtrl = TextEditingController();

  int rolId = 0;
  int estado = 1;

  bool cargandoPermisos = false;
  bool guardando = false;

  List<int> modulosSeleccionados = [];

  bool get editando => widget.usuario != null;

  @override
  void initState() {
    super.initState();

    rolId = widget.roles.isNotEmpty ? widget.roles.first.id : 0;

    final u = widget.usuario;

    if (u != null) {
      rolId = u.rolId;
      usuarioCtrl.text = u.usuario;
      nombresCtrl.text = u.nombres;
      apellidosCtrl.text = u.apellidos;
      correoCtrl.text = u.correo;
      estado = u.estado;

      _cargarPermisos(u.id);
    }
  }

  Future<void> _cargarPermisos(int usuarioId) async {
    setState(() {
      cargandoPermisos = true;
    });

    try {
      final permisos =
          await widget.usuarioService.listarUsuarioModulos(usuarioId);

      if (!mounted) return;

      setState(() {
        modulosSeleccionados = permisos;
      });
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) {
        setState(() {
          cargandoPermisos = false;
        });
      }
    }
  }

  @override
  void dispose() {
    usuarioCtrl.dispose();
    passwordCtrl.dispose();
    nombresCtrl.dispose();
    apellidosCtrl.dispose();
    correoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (usuarioCtrl.text.trim().isEmpty) {
      _mensaje('Ingrese el usuario.', error: true);
      return;
    }

    if (nombresCtrl.text.trim().isEmpty) {
      _mensaje('Ingrese los nombres.', error: true);
      return;
    }

    if (!editando && passwordCtrl.text.trim().isEmpty) {
      _mensaje('Ingrese la contraseña.', error: true);
      return;
    }

    if (rolId <= 0) {
      _mensaje('Seleccione un rol válido.', error: true);
      return;
    }

    setState(() {
      guardando = true;
    });

    final u = UsuarioModel(
      id: widget.usuario?.id ?? 0,
      rolId: rolId,
      usuario: usuarioCtrl.text.trim(),
      nombres: nombresCtrl.text.trim(),
      apellidos: apellidosCtrl.text.trim(),
      correo: correoCtrl.text.trim(),
      estado: estado,
      fechaRegistro: '',
    );

    final respUsuario = await widget.usuarioService.guardarUsuario(
      usuario: u,
      password: passwordCtrl.text.trim(),
    );

    final successUsuario = respUsuario['success'] == true;

    if (!successUsuario) {
      if (!mounted) return;

      setState(() {
        guardando = false;
      });

      _mensaje(
        respUsuario['message']?.toString() ?? 'No se pudo guardar usuario.',
        error: true,
      );
      return;
    }

    final data = respUsuario['data'];
    final usuarioId = data is Map
        ? int.tryParse(data['id']?.toString() ?? '0') ?? 0
        : widget.usuario?.id ?? 0;

    if (usuarioId > 0) {
      final respPermisos =
          await widget.usuarioService.guardarUsuarioModulos(
        usuarioId: usuarioId,
        modulos: modulosSeleccionados,
      );

      if (respPermisos['success'] != true) {
        if (!mounted) return;

        setState(() {
          guardando = false;
        });

        _mensaje(
          respPermisos['message']?.toString() ??
              'Usuario guardado, pero no se pudieron guardar permisos.',
          error: true,
        );
        return;
      }
    }

    if (!mounted) return;

    setState(() {
      guardando = false;
    });

    _mensaje(
      editando
          ? 'Usuario actualizado correctamente.'
          : 'Usuario registrado correctamente.',
    );

    Navigator.pop(context, true);
  }

  void _mensaje(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _moduloTile(ModuloModel modulo) {
    final seleccionado = modulosSeleccionados.contains(modulo.id);

    return CheckboxListTile(
      value: seleccionado,
      activeColor: const Color(0xFFF97316),
      title: Text(
        modulo.nombre,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Ruta: ${modulo.ruta}'),
      onChanged: guardando
          ? null
          : (value) {
              setState(() {
                if (value == true) {
                  modulosSeleccionados.add(modulo.id);
                } else {
                  modulosSeleccionados.remove(modulo.id);
                }
              });
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
      padding: EdgeInsets.fromLTRB(18, 18, 18, bottom + 18),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    editando ? 'Editar usuario' : 'Nuevo usuario',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                IconButton(
                  onPressed:
                      guardando ? null : () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _campo(
              controller: nombresCtrl,
              label: 'Nombres',
              icon: Icons.badge_outlined,
            ),
            _campo(
              controller: apellidosCtrl,
              label: 'Apellidos',
              icon: Icons.badge,
            ),
            _campo(
              controller: usuarioCtrl,
              label: 'Usuario',
              icon: Icons.person_outline,
            ),
            _campo(
              controller: correoCtrl,
              label: 'Correo',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            _campo(
              controller: passwordCtrl,
              label: editando
                  ? 'Nueva contraseña (opcional)'
                  : 'Contraseña',
              icon: Icons.lock_outline,
              obscure: true,
            ),

            const SizedBox(height: 4),

            DropdownButtonFormField<int>(
              value: rolId > 0 ? rolId : null,
              decoration: InputDecoration(
                labelText: 'Rol',
                prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: widget.roles.map((rol) {
                return DropdownMenuItem<int>(
                  value: rol.id,
                  child: Text(rol.nombre),
                );
              }).toList(),
              onChanged: guardando
                  ? null
                  : (value) {
                      setState(() {
                        rolId = value ?? 0;
                      });
                    },
            ),

            const SizedBox(height: 12),

            SwitchListTile(
              value: estado == 1,
              activeColor: const Color(0xFFF97316),
              title: const Text(
                'Usuario activo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Permite o bloquea el acceso al sistema.'),
              onChanged: guardando
                  ? null
                  : (value) {
                      setState(() {
                        estado = value ? 1 : 0;
                      });
                    },
            ),

            const SizedBox(height: 12),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Permisos de módulos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (cargandoPermisos)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF97316),
                          ),
                        ),
                      )
                    else if (widget.modulos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(14),
                        child: Text(
                          'No hay módulos activos registrados.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    else
                      ...widget.modulos.map(_moduloTile),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: guardando ? null : _guardar,
                icon: guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  guardando ? 'Guardando...' : 'Guardar usuario',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
