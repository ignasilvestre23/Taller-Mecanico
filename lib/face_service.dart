import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Similitud coseno mínima. En MobileFaceNet la misma persona suele dar 0.6–0.9; calibrar con tus pruebas.
const kThreshold = 0.70;
const kLivenessSeconds = 8; // el PDF pide 5s; con takePicture conviene más margen
const kMaxAttempts = 3;

enum Challenge {
  blink('Parpadee'),
  smile('Sonría'),
  turn('Gire la cabeza hacia un costado');

  final String text;
  const Challenge(this.text);
}

class FaceService {
  static List<double> average(List<List<double>> s) {
    final m = List.generate(
        s.first.length, (i) => s.map((e) => e[i]).reduce((a, b) => a + b) / s.length);
    final n = sqrt(m.fold(0.0, (t, e) => t + e * e));
    return m.map((e) => e / n).toList();
  }

  /// Similitud coseno de embeddings normalizados (1.0 = idéntico).
  static double similarity(List<double> a, List<double> b) {
    double d = 0;
    for (var i = 0; i < a.length; i++) {
      d += a[i] * b[i];
    }
    return d;
  }

  static bool passed(Challenge c, Face f) => switch (c) {
        Challenge.blink => (f.leftEyeOpenProbability ?? 1) < 0.25 &&
            (f.rightEyeOpenProbability ?? 1) < 0.25,
        Challenge.smile => (f.smilingProbability ?? 0) > 0.8,
        Challenge.turn => (f.headEulerAngleY ?? 0).abs() > 20,
      };

  static bool isFrontal(Face f) =>
      (f.headEulerAngleY ?? 0).abs() < 10 && (f.leftEyeOpenProbability ?? 1) > 0.6;
}
