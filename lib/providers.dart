import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'repository.dart';

const _store = FlutterSecureStorage();

// ---------- Auditoría ----------
class AuditNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];
  void add(String msg) =>
      state = ['${DateTime.now().toIso8601String().substring(0, 19)}  $msg', ...state];
}

final auditProvider = NotifierProvider<AuditNotifier, List<String>>(AuditNotifier.new);

// ---------- Autenticación ----------
class AuthState {
  final bool loggedIn;
  final List<double>? template;
  const AuthState({this.loggedIn = false, this.template});
  AuthState copy({bool? loggedIn, List<double>? template}) =>
      AuthState(loggedIn: loggedIn ?? this.loggedIn, template: template ?? this.template);
}

class AuthNotifier extends Notifier<AuthState> {
  static const pin = '1234'; // DEMO: usuario único. Reemplazar por backend real.

  @override
  AuthState build() {
    _load();
    return const AuthState();
  }

  Future<void> _load() async {
    final t = await _store.read(key: 'face_template'); // cifrado en Keystore/Keychain
    if (t != null) {
      state = state.copy(
          template: (jsonDecode(t) as List).map((e) => (e as num).toDouble()).toList());
    }
  }

  Future<void> enroll(List<double> t) async {
    await _store.write(key: 'face_template', value: jsonEncode(t));
    state = state.copy(template: t);
    ref.read(auditProvider.notifier).add('Enrolamiento facial exitoso');
  }

  bool loginPin(String p) {
    final ok = p == pin;
    ref.read(auditProvider.notifier).add('Login PIN ${ok ? "OK" : "FALLIDO"}');
    if (ok) state = state.copy(loggedIn: true);
    return ok;
  }

  void loginFace() => state = state.copy(loggedIn: true);
  void logout() => state = state.copy(loggedIn: false);
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// ---------- Datos del taller (capa genérica sobre Repo) ----------
final repoProvider = Provider<Repo>((_) => makeRepo());

/// Colecciones: clientes, vehiculos, repuestos, ordenes, turnos
final colProvider = FutureProvider.family<List<Rec>, String>(
    (ref, col) => ref.read(repoProvider).list(col));

Future<void> guardar(WidgetRef ref, String col, Rec r) async {
  r['id'] ??= DateTime.now().microsecondsSinceEpoch.toString();
  await ref.read(repoProvider).save(col, r);
  ref.invalidate(colProvider(col));
}

Future<void> borrar(WidgetRef ref, String col, String id) async {
  await ref.read(repoProvider).remove(col, id);
  ref.invalidate(colProvider(col));
}
