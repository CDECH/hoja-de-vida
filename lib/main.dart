import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Hoja de vida de Daniel',
      debugShowCheckedModeBanner: false,
      home: HojaDeVida(),
    );
  }
}

class HojaDeVida extends StatefulWidget {
  const HojaDeVida({super.key});

  @override
  State<HojaDeVida> createState() => _HojaDeVidaState();
}

class _HojaDeVidaState extends State<HojaDeVida> {
  late final WebViewController _controller;

  bool _oscuro = false;
  bool _lista = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'TemaFlutter',
        onMessageReceived: (mensaje) {
          if (!mounted) return;

          final oscuro = mensaje.message == 'true';

          if (_oscuro != oscuro) {
            setState(() => _oscuro = oscuro);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;

            setState(() {
              _lista = false;
              _error = null;
            });
          },
          onPageFinished: (_) async {
            final temaActual = _oscuro;

            try {
              await _controller.runJavaScript(
                'window.aplicarTema($temaActual);',
              );

              if (!mounted) return;

              setState(() => _lista = true);
            } catch (_) {
              if (!mounted) return;

              setState(() {
                _error =
                    'No se pudo preparar la página. '
                    'Comprueba que script.js tenga el código completo.';
              });
            }
          },
          onWebResourceError: (error) {
            if (!mounted) return;

            setState(() {
              _lista = false;
              _error = 'Error al cargar la página: ${error.description}';
            });
          },
        ),
      );

    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _lista = false;
      _error = null;
    });

    try {
      await _controller.loadFlutterAsset('assets/web/index.html');
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error =
            'No se pudo abrir index.html. '
            'Revisa la carpeta assets/web y pubspec.yaml.';
      });
    }
  }

  Future<void> _cambiarTema() async {
    final nuevoTema = !_oscuro;

    try {
      await _controller.runJavaScript(
        'window.aplicarTema($nuevoTema);',
      );

      if (!mounted) return;

      setState(() => _oscuro = nuevoTema);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cambiar el tema. Pulsa recargar.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1754A5),
          brightness: _oscuro ? Brightness.dark : Brightness.light,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi hoja de vida'),
          actions: [
            IconButton(
              tooltip: _oscuro ? 'Tema claro' : 'Tema oscuro',
              onPressed: _lista ? _cambiarTema : null,
              icon: Icon(
                _oscuro ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
            IconButton(
              tooltip: 'Recargar página',
              onPressed: _cargar,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (!_lista && _error == null)
                const LinearProgressIndicator(),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: WebViewWidget(
                  controller: _controller,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}