import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

typedef Rec = Map<String, dynamic>;

abstract class Repo {
  Future<List<Rec>> list(String col);
  Future<void> save(String col, Rec r);
  Future<void> remove(String col, String id);
}

class MemoryRepo implements Repo {
  final _db = <String, Map<String, Rec>>{};
  @override
  Future<List<Rec>> list(String col) async => (_db[col]?.values ?? []).map((e) => Rec.of(e)).toList();
  @override
  Future<void> save(String col, Rec r) async => (_db[col] ??= {})[r['id']] = Rec.of(r);
  @override
  Future<void> remove(String col, String id) async => _db[col]?.remove(id);
}

class FirestoreRepo implements Repo {
  final _fs = FirebaseFirestore.instance;
  @override
  Future<List<Rec>> list(String col) async =>
      (await _fs.collection(col).get()).docs.map((d) => {...d.data(), 'id': d.id}).toList();
  @override
  Future<void> save(String col, Rec r) => _fs.collection(col).doc(r['id']).set(r);
  @override
  Future<void> remove(String col, String id) => _fs.collection(col).doc(id).delete();
}

/// Contrato compatible con json-server: GET /col, PUT /col/:id, POST /col, DELETE /col/:id
class RestRepo implements Repo {
  static const _h = {'Content-Type': 'application/json'};
  Uri _u(String p) => Uri.parse('$restBaseUrl/$p');
  @override
  Future<List<Rec>> list(String col) async =>
      (jsonDecode((await http.get(_u(col))).body) as List).cast<Rec>();
  @override
  Future<void> save(String col, Rec r) async {
    final res = await http.put(_u('$col/${r['id']}'), headers: _h, body: jsonEncode(r));
    if (res.statusCode == 404) await http.post(_u(col), headers: _h, body: jsonEncode(r));
  }
  @override
  Future<void> remove(String col, String id) async => http.delete(_u('$col/$id'));
}

Repo makeRepo() => switch (backend) {
      BackendType.memory => MemoryRepo(),
      BackendType.firebase => FirestoreRepo(),
      BackendType.rest => RestRepo(),
    };
