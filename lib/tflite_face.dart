import 'dart:io';
import 'dart:math';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Requiere assets/models/mobilefacenet.tflite (entrada 112x112x3, salida vector de embedding).
class TfliteFace {
  static Interpreter? _it;
  static Future<Interpreter> _load() async =>
      _it ??= await Interpreter.fromAsset('assets/models/mobilefacenet.tflite');

  static Future<List<double>> embed(String path, Face face) async {
    final it = await _load();
    final dim = it.getOutputTensor(0).shape.last;
    final image = img.bakeOrientation(img.decodeImage(await File(path).readAsBytes())!);
    final b = face.boundingBox;
    final x = max(0, b.left.toInt()), y = max(0, b.top.toInt());
    final crop = img.copyResize(
        img.copyCrop(image,
            x: x, y: y,
            width: min(image.width - x, b.width.toInt()),
            height: min(image.height - y, b.height.toInt())),
        width: 112, height: 112);
    final input = [
      List.generate(112, (yy) => List.generate(112, (xx) {
            final p = crop.getPixel(xx, yy);
            return [(p.r - 127.5) / 128, (p.g - 127.5) / 128, (p.b - 127.5) / 128];
          }))
    ];
    final out = [List.filled(dim, 0.0)];
    it.run(input, out);
    final n = sqrt(out[0].fold(0.0, (s, e) => s + e * e));
    return out[0].map((e) => e / n).toList();
  }
}
