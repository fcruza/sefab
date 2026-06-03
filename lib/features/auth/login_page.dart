import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/providers/auth_provider.dart';
import '../modules/modules_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usuarioCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  bool cargando = false;
  bool ocultarPassword = true;

  @override
  void dispose() {
    usuarioCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _loginNormal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      cargando = true;
    });

    try {
      final auth = context.read<AuthProvider>();

      await auth.login(
        usuarioCtrl.text.trim(),
        passwordCtrl.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      /*
       * Solo pregunta activar huella si todavía no está activada.
       */
      if (!auth.biometricEnabled) {
        final activarHuella = await _preguntarActivarHuella();

        if (activarHuella == true) {
          final ok = await auth.requestEnableBiometric();

          if (!mounted) return;

          if (ok) {
            _mensaje('Ingreso con huella activado correctamente.');
          } else {
            _mensaje('No se pudo activar la huella.');
          }
        }
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ModulesPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _mensaje(
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  Future<bool?> _preguntarActivarHuella() async {
    final puedeUsar = await context.read<AuthProvider>().canUseBiometrics();

    if (!puedeUsar) {
      return false;
    }

    if (!mounted) return false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Activar ingreso con huella'),
          content: const Text(
            '¿Deseas activar el ingreso con huella para las próximas sesiones?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('No, gracias'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, true);
              },
              icon: const Icon(Icons.fingerprint),
              label: const Text('Activar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loginHuella() async {
    setState(() {
      cargando = true;
    });

    try {
      final ok = await context.read<AuthProvider>().biometricLogin();

      if (!mounted) return;

      if (ok) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ModulesPage(),
          ),
        );
      } else {
        _mensaje('No se pudo usar la huella.');
      }
    } catch (e) {
      if (!mounted) return;
      _mensaje('No se pudo validar la huella.');
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color sefPrimary = Color(0xFF1F2937);
    const Color sefAccent = Color(0xFFF97316);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: const Color(0xFFF3F4F6),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.35),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.94),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/logo_sefab.png',
                                  width: 320,
                                  height: 130,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      width: 160,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: sefPrimary,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: const Icon(
                                        Icons.business_center,
                                        color: sefAccent,
                                        size: 56,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Sistema de gestión técnica',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 28),
                              TextFormField(
                                controller: usuarioCtrl,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'Usuario',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: sefAccent,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingrese su usuario';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: passwordCtrl,
                                obscureText: ocultarPassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _loginNormal(),
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: sefAccent,
                                      width: 1.5,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        ocultarPassword = !ocultarPassword;
                                      });
                                    },
                                    icon: Icon(
                                      ocultarPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Ingrese su contraseña';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: cargando ? null : _loginNormal,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: sefAccent,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        sefAccent.withOpacity(0.55),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                  ),
                                  icon: cargando
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.login),
                                  label: Text(
                                    cargando ? 'Validando...' : 'Ingresar',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton.icon(
                                  onPressed: cargando ? null : _loginHuella,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: sefPrimary,
                                    backgroundColor:
                                        Colors.white.withOpacity(0.70),
                                    side: const BorderSide(
                                      color: sefPrimary,
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(Icons.fingerprint),
                                  label: const Text(
                                    'Ingresar con huella',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.70),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Versión 1.0.0',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}