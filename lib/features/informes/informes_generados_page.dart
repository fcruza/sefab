import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'informe_service.dart';

class InformesGeneradosPage extends StatefulWidget {
  const InformesGeneradosPage({super.key});

  @override
  State<InformesGeneradosPage> createState() => _InformesGeneradosPageState();
}

class _InformesGeneradosPageState extends State<InformesGeneradosPage> {
  final InformeService informeService = InformeService();
  final TextEditingController buscarCtrl = TextEditingController();

  List<Map<String, dynamic>> informes = [];
  bool cargando = false;
  String? error;

  int mesSeleccionado = 0;
  int anioSeleccionado = 2026;

  final List<_FiltroMes> meses = const [
    _FiltroMes(numero: 0, nombre: 'Todos'),
    _FiltroMes(numero: 5, nombre: 'Mayo'),
    _FiltroMes(numero: 6, nombre: 'Junio'),
    _FiltroMes(numero: 7, nombre: 'Julio'),
  ];

  @override
  void initState() {
    super.initState();
    _cargarInformes();
  }

  @override
  void dispose() {
    buscarCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarInformes() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final data = await informeService.listarInformes(
        mes: mesSeleccionado == 0 ? null : mesSeleccionado,
        anio: anioSeleccionado,
        buscar: buscarCtrl.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        informes = data;
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

  String _texto(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Future<void> _abrirPdf(String url) async {
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El informe no tiene PDF disponible.'),
        ),
      );
      return;
    }

    final uri = Uri.parse(url);

    try {
      final abierto = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!abierto && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el PDF.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir el PDF: $e'),
        ),
      );
    }
  }

  void _enviarCorreo(Map<String, dynamic> informe) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Luego conectaremos el envío por correo de ${_texto(informe['numero_informe'])}.',
        ),
      ),
    );
  }

  Color _estadoEnvioColor(int enviado) {
    return enviado == 1 ? const Color(0xFF16A34A) : const Color(0xFFF97316);
  }

  String _estadoEnvioTexto(int enviado) {
    return enviado == 1 ? 'Enviado' : 'Pendiente de envío';
  }

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);
    const Color sefAccent = Color(0xFFF97316);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Informes generados'),
        backgroundColor: sefPrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: cargando ? null : _cargarInformes,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            decoration: const BoxDecoration(
              color: sefPrimary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historial de informes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${informes.length} informe(s) generado(s)',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: buscarCtrl,
                  onSubmitted: (_) => _cargarInformes(),
                  decoration: InputDecoration(
                    hintText: 'Buscar por número, cliente o asunto',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: buscarCtrl.text.trim().isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              buscarCtrl.clear();
                              _cargarInformes();
                            },
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: meses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final mes = meses[index];
                      final selected = mes.numero == mesSeleccionado;

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: cargando
                            ? null
                            : () {
                                setState(() {
                                  mesSeleccionado = mes.numero;
                                });
                                _cargarInformes();
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? sefAccent : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            mes.nombre,
                            style: TextStyle(
                              color: selected ? Colors.white : sefPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: cargando
                ? const Center(
                    child: CircularProgressIndicator(
                      color: sefAccent,
                    ),
                  )
                : error != null
                    ? Center(
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
                                onPressed: _cargarInformes,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : informes.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay informes generados.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : RefreshIndicator(
                            color: sefAccent,
                            onRefresh: _cargarInformes,
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                MediaQuery.of(context).padding.bottom + 110,
                              ),
                              itemCount: informes.length,
                              itemBuilder: (context, index) {
                                final informe = informes[index];

                                final numero = _texto(
                                  informe['numero_informe'],
                                );
                                final periodo = _texto(informe['periodo']);
                                final cliente = _texto(informe['cliente']);
                                final fechaRegistro = _texto(
                                  informe['fecha_registro'],
                                );
                                final total = _texto(
                                  informe['total_programados'],
                                );
                                final cumplidos = _texto(
                                  informe['cumplidos'],
                                );
                                final porcentaje = _texto(
                                  informe['porcentaje_cumplimiento'],
                                );
                                final enviado = int.tryParse(
                                      _texto(informe['enviado_correo']),
                                    ) ??
                                    0;
                                final urlPdf = _texto(informe['url_pdf']);
                                final estadoColor = _estadoEnvioColor(enviado);

                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.only(bottom: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 52,
                                              height: 52,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFEDD5),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: const Icon(
                                                Icons.picture_as_pdf,
                                                color: sefAccent,
                                                size: 30,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    numero,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    '$periodo · $cliente',
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuButton<String>(
                                              onSelected: (value) {
                                                if (value == 'abrir') {
                                                  _abrirPdf(urlPdf);
                                                } else if (value == 'correo') {
                                                  _enviarCorreo(informe);
                                                }
                                              },
                                              itemBuilder: (_) => const [
                                                PopupMenuItem(
                                                  value: 'abrir',
                                                  child: Text('Abrir PDF'),
                                                ),
                                                PopupMenuItem(
                                                  value: 'correo',
                                                  child: Text('Enviar correo'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            _InformeChip(
                                              icon: Icons.event,
                                              text: periodo,
                                            ),
                                            _InformeChip(
                                              icon: Icons.calendar_today,
                                              text: fechaRegistro,
                                            ),
                                            Chip(
                                              avatar: Icon(
                                                Icons.circle,
                                                size: 12,
                                                color: estadoColor,
                                              ),
                                              label: Text(
                                                _estadoEnvioTexto(enviado),
                                                style: TextStyle(
                                                  color: estadoColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              backgroundColor:
                                                  estadoColor.withOpacity(0.10),
                                              side: BorderSide.none,
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 24),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _ResumenMini(
                                                label: 'Programados',
                                                value: total,
                                              ),
                                            ),
                                            Expanded(
                                              child: _ResumenMini(
                                                label: 'Cumplidos',
                                                value: cumplidos,
                                              ),
                                            ),
                                            Expanded(
                                              child: _ResumenMini(
                                                label: 'Avance',
                                                value: '$porcentaje%',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: () =>
                                                    _abrirPdf(urlPdf),
                                                icon: const Icon(
                                                  Icons.open_in_new,
                                                ),
                                                label: const Text('Abrir PDF'),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () =>
                                                    _enviarCorreo(informe),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: sefAccent,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      14,
                                                    ),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.email_outlined,
                                                ),
                                                label: const Text('Enviar'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _FiltroMes {
  final int numero;
  final String nombre;

  const _FiltroMes({
    required this.numero,
    required this.nombre,
  });
}

class _InformeChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InformeChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text.trim().isEmpty ? 'No registrado' : text),
      backgroundColor: const Color(0xFFF3F4F6),
      side: BorderSide.none,
    );
  }
}

class _ResumenMini extends StatelessWidget {
  final String label;
  final String value;

  const _ResumenMini({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final texto = value.trim().isEmpty ? '0' : value;

    return Column(
      children: [
        Text(
          texto,
          style: const TextStyle(
            color: Color(0xFFF97316),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}