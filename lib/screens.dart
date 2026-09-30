import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'face_service.dart';
import 'tflite_face.dart';
import 'providers.dart';

// ======================= LOGIN =======================
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _pin = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    final hasFace = ref.watch(authProvider.select((s) => s.template != null));
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.car_repair, size: 80, color: Colors.deepOrange),
              const Text('Taller Mecánico',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: hasFace
                    ? () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const FaceScreen(FaceMode.login)))
                    : null,
                icon: const Icon(Icons.face),
                label: const Text('Iniciar sesión con rostro'),
              ),
              if (!hasFace)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Ingrese con PIN y registre su rostro en Seguridad.',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                ),
              const Divider(height: 40),
              TextField(
                controller: _pin,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'PIN (demo: 1234)',
                    errorText: _error,
                    border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  if (!ref.read(authProvider.notifier).loginPin(_pin.text)) {
                    setState(() => _error = 'PIN incorrecto');
                  }
                },
                child: const Text('Ingresar con PIN'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ======================= CÁMARA FACIAL =======================
enum FaceMode { enroll, login }

class FaceScreen extends ConsumerStatefulWidget {
  final FaceMode mode;
  const FaceScreen(this.mode, {super.key});
  @override
  ConsumerState<FaceScreen> createState() => _FaceScreenState();
}

class _FaceScreenState extends ConsumerState<FaceScreen> {
  CameraController? _cam;
  final _det = FaceDetector(
      options: FaceDetectorOptions(
          enableClassification: true,
          enableLandmarks: true,
          performanceMode: FaceDetectorMode.accurate));
  String _msg = 'Preparando cámara...';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _cam?.dispose();
    _det.close();
    super.dispose();
  }

  void _say(String m) {
    if (mounted) setState(() => _msg = m);
  }

  Future<void> _init() async {
    try {
      final cams = await availableCameras();
      final front = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cams.first);
      _cam = CameraController(front, ResolutionPreset.medium, enableAudio: false);
      await _cam!.initialize();
      if (!mounted) return;
      setState(() {});
      widget.mode == FaceMode.enroll ? await _enroll() : await _login();
    } catch (_) {
      _finish('No se pudo acceder a la cámara. Verifique los permisos.');
    }
  }

  Future<(Face, String)?> _snap() async {
    final file = await _cam!.takePicture();
    final faces = await _det.processImage(InputImage.fromFilePath(file.path));
    return faces.length == 1 ? (faces.first, file.path) : null;
  }

  Future<void> _finish(String msg) async {
    _say(msg);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context);
  }

  // ---- Enrolamiento: 5 capturas de calidad promediadas ----
  Future<void> _enroll() async {
    final samples = <List<double>>[];
    for (var tries = 0; samples.length < 5 && tries < 30 && mounted; tries++) {
      final s = await _snap();
      final f = s?.$1;
      if (f == null) {
        _say('No se detecta un rostro. Mejore la iluminación y retire obstáculos.');
      } else if ((f.headEulerAngleY ?? 0).abs() > 12) {
        _say('Mire de frente a la cámara');
      } else {
        samples.add(await TfliteFace.embed(s!.$2, f));
        _say('Captura ${samples.length}/5');
      }
    }
    if (samples.length < 5) return _finish('No se pudo completar el registro.');
    await ref.read(authProvider.notifier).enroll(FaceService.average(samples));
    _finish('¡Registro exitoso!');
  }

  // ---- Login 1:1 con prueba de vida aleatoria ----
  Future<void> _login() async {
    final template = ref.read(authProvider).template!;
    final audit = ref.read(auditProvider.notifier);
    for (var attempt = 1; attempt <= kMaxAttempts && mounted; attempt++) {
      final ch = Challenge.values[Random().nextInt(Challenge.values.length)];
      _say('${ch.text} (intento $attempt/$kMaxAttempts)');
      final end = DateTime.now().add(const Duration(seconds: kLivenessSeconds));
      List<double>? frontal;
      var live = false;
      while (DateTime.now().isBefore(end) && !live && mounted) {
        final s = await _snap();
        if (s == null) continue;
        final f = s.$1;
        if (FaceService.isFrontal(f)) frontal = await TfliteFace.embed(s.$2, f);
        live = FaceService.passed(ch, f);
      }
      final score = frontal == null ? 0.0 : FaceService.similarity(frontal, template);
      final ok = live && score >= kThreshold;
      audit.add('Login facial ${ok ? "OK" : "FALLIDO"} | desafío=${ch.name} '
          'liveness=$live | similitud=${score.toStringAsFixed(3)}');
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context);
        ref.read(authProvider.notifier).loginFace();
        return;
      }
      _say(live ? 'No se pudo verificar la identidad.' : 'Intento no válido');
      await Future.delayed(const Duration(seconds: 1));
    }
    _finish('Demasiados intentos. Ingrese con su PIN.');
  }

  @override
  Widget build(BuildContext context) {
    final ready = _cam?.value.isInitialized ?? false;
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.mode == FaceMode.enroll ? 'Registrar rostro' : 'Verificación facial')),
      body: Column(children: [
        const SizedBox(height: 24),
        Expanded(
          child: Center(
            child: ready
                ? ClipOval(
                    child: SizedBox(
                        width: 300, height: 380,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                              width: _cam!.value.previewSize!.height,
                              height: _cam!.value.previewSize!.width,
                              child: CameraPreview(_cam!)),
                        )))
                : const CircularProgressIndicator(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_msg, textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
        ),
      ]),
    );
  }
}

