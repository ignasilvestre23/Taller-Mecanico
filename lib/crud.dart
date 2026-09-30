import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';
import 'repository.dart';

enum Tipo { texto, numero, fecha, opcion, ref }

class Campo {
  final String key, label, col;
  final Tipo tipo;
  final List<String> opciones;
  const Campo(this.key, this.label,
      {this.tipo = Tipo.texto, this.opciones = const [], this.col = ''});
}

class Accion {
  final String label;
  final Future<void> Function(BuildContext, WidgetRef, Rec) fn;
  Accion(this.label, this.fn);
}

class Entidad {
  final String col, titulo;
  final List<Campo> campos;
  final String Function(Rec) encabezado;
  final String Function(Rec, String Function(String col, dynamic id)) sub;
  final List<Accion> acciones;
  Entidad(this.col, this.titulo, this.campos,
      {required this.encabezado, required this.sub, this.acciones = const []});
}

String etiqueta(Rec r) => '${r['nombre'] ?? r['patente'] ?? r['id']}';

class CrudScreen extends ConsumerWidget {
  final Entidad e;
  const CrudScreen(this.e, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(colProvider(e.col));
    final rels = {
      for (final c in e.campos.where((c) => c.tipo == Tipo.ref))
        c.col: ref.watch(colProvider(c.col)).valueOrNull ?? <Rec>[]
    };
    String nombre(String col, dynamic id) {
      final r = (rels[col] ?? []).where((x) => x['id'] == id).firstOrNull;
      return r == null ? '—' : etiqueta(r);
    }

    return Scaffold(
      floatingActionButton:
          FloatingActionButton(onPressed: () => formulario(context, ref, e), child: const Icon(Icons.add)),
      body: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error de conexión: $err')),
        data: (l) => l.isEmpty
            ? const Center(child: Text('Sin registros'))
            : ListView(children: [
                for (final r in l)
                  ListTile(
                    title: Text(e.encabezado(r)),
                    subtitle: Text(e.sub(r, nombre)),
                    onTap: () => formulario(context, ref, e, r),
                    trailing: PopupMenuButton<int>(
                      onSelected: (i) => i < 0
                          ? borrar(ref, e.col, r['id'])
                          : e.acciones[i].fn(context, ref, r),
                      itemBuilder: (_) => [
                        for (var i = 0; i < e.acciones.length; i++)
                          PopupMenuItem(value: i, child: Text(e.acciones[i].label)),
                        const PopupMenuItem(value: -1, child: Text('Eliminar')),
                      ],
                    ),
                  ),
              ]),
      ),
    );
  }
}

Future<void> formulario(BuildContext ctx, WidgetRef ref, Entidad e, [Rec? actual]) {
  final data = <String, dynamic>{...?actual};
  final refs = {
    for (final c in e.campos.where((c) => c.tipo == Tipo.ref))
      c.key: ref.read(colProvider(c.col)).valueOrNull ?? <Rec>[]
  };
  final ctrls = {for (final c in e.campos) c.key: TextEditingController(text: '${data[c.key] ?? ''}')};
  return showDialog(
    context: ctx,
    builder: (_) => StatefulBuilder(
      builder: (dctx, set) => AlertDialog(
        title: Text(actual == null ? 'Nuevo · ${e.titulo}' : 'Editar · ${e.titulo}'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            for (final c in e.campos)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: switch (c.tipo) {
                  Tipo.texto || Tipo.numero => TextField(
                      controller: ctrls[c.key],
                      keyboardType: c.tipo == Tipo.numero ? TextInputType.number : null,
                      decoration: InputDecoration(labelText: c.label)),
                  Tipo.fecha => OutlinedButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                            context: dctx,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100));
                        if (d != null) set(() => data[c.key] = d.toIso8601String().substring(0, 10));
                      },
                      child: Text('${c.label}: ${data[c.key] ?? "elegir"}')),
                  Tipo.opcion => DropdownButtonFormField<String>(
                      value: c.opciones.contains(data[c.key]) ? data[c.key] : null,
                      items: [for (final o in c.opciones) DropdownMenuItem(value: o, child: Text(o))],
                      onChanged: (v) => data[c.key] = v,
                      decoration: InputDecoration(labelText: c.label)),
                  Tipo.ref => DropdownButtonFormField<String>(
                      value: refs[c.key]!.any((r) => r['id'] == data[c.key]) ? data[c.key] : null,
                      items: [
                        for (final r in refs[c.key]!)
                          DropdownMenuItem(value: r['id'] as String, child: Text(etiqueta(r)))
                      ],
                      onChanged: (v) => data[c.key] = v,
                      decoration: InputDecoration(labelText: c.label)),
                },
              ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              for (final c in e.campos) {
                if (c.tipo == Tipo.texto) data[c.key] = ctrls[c.key]!.text.trim();
                if (c.tipo == Tipo.numero) data[c.key] = num.tryParse(ctrls[c.key]!.text) ?? 0;
              }
              await guardar(ref, e.col, data);
              if (dctx.mounted) Navigator.pop(dctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}
