import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'crud.dart';
import 'providers.dart';
import 'repository.dart';
import 'screens.dart';

const estados = ['pendiente', 'en proceso', 'listo', 'entregado'];

num totalOrden(Rec o) =>
    (o['manoDeObra'] ?? 0) +
    ((o['repuestos'] as List?) ?? []).fold<num>(0, (s, i) => s + (i['cant'] as num) * (i['precio'] as num));

final clientes = Entidad('clientes', 'Clientes',
    const [Campo('nombre', 'Nombre'), Campo('telefono', 'Teléfono'), Campo('email', 'Email')],
    encabezado: (r) => '${r['nombre']}', sub: (r, _) => '${r['telefono'] ?? ''} · ${r['email'] ?? ''}');

final vehiculos = Entidad(
    'vehiculos',
    'Vehículos',
    const [
      Campo('patente', 'Patente'),
      Campo('marca', 'Marca'),
      Campo('modelo', 'Modelo'),
      Campo('anio', 'Año', tipo: Tipo.numero),
      Campo('km', 'Kilometraje', tipo: Tipo.numero),
      Campo('clienteId', 'Cliente', tipo: Tipo.ref, col: 'clientes'),
    ],
    encabezado: (r) => '${r['patente']} · ${r['marca']} ${r['modelo']}',
    sub: (r, n) => 'Dueño: ${n('clientes', r['clienteId'])} · ${r['km'] ?? 0} km',
    acciones: [
      Accion('Ver historial', (ctx, ref, v) async {
        final os = (ref.read(colProvider('ordenes')).valueOrNull ?? []).where((o) => o['vehiculoId'] == v['id']);
        showDialog(
            context: ctx,
            builder: (_) => AlertDialog(
                  title: Text('Historial ${v['patente']}'),
                  content: Text(os.isEmpty
                      ? 'Sin órdenes'
                      : os.map((o) => '• ${o['descripcion']} (${o['estado']}) \$${totalOrden(o)}').join('\n')),
                ));
      })
    ]);

final repuestos = Entidad(
    'repuestos',
    'Repuestos / Stock',
    const [
      Campo('nombre', 'Nombre'),
      Campo('codigo', 'Código'),
      Campo('stock', 'Stock', tipo: Tipo.numero),
      Campo('stockMinimo', 'Stock mínimo', tipo: Tipo.numero),
      Campo('precio', 'Precio', tipo: Tipo.numero),
    ],
    encabezado: (r) => '${r['nombre']} (${r['codigo'] ?? '-'})',
    sub: (r, _) =>
        'Stock ${r['stock']} · \$${r['precio']}${(r['stock'] ?? 0) <= (r['stockMinimo'] ?? 0) ? '  ⚠ stock bajo' : ''}');

final ordenes = Entidad(
    'ordenes',
    'Órdenes de trabajo',
    const [
      Campo('vehiculoId', 'Vehículo', tipo: Tipo.ref, col: 'vehiculos'),
      Campo('descripcion', 'Trabajo a realizar'),
      Campo('manoDeObra', 'Mano de obra \$', tipo: Tipo.numero),
      Campo('estado', 'Estado', tipo: Tipo.opcion, opciones: estados),
    ],
    encabezado: (r) => '${r['descripcion']}',
    sub: (r, n) => '${n('vehiculos', r['vehiculoId'])} · ${r['estado'] ?? 'pendiente'} · Total \$${totalOrden(r)}',
    acciones: [
      Accion('Agregar repuesto', agregarRepuesto),
      Accion('Avanzar estado', (ctx, ref, o) async {
        final i = estados.indexOf(o['estado'] ?? 'pendiente');
        o['estado'] = estados[(i + 1).clamp(0, estados.length - 1)];
        await guardar(ref, 'ordenes', o);
      }),
    ]);

final turnos = Entidad(
    'turnos',
    'Turnos',
    const [
      Campo('fecha', 'Fecha', tipo: Tipo.fecha),
      Campo('vehiculoId', 'Vehículo', tipo: Tipo.ref, col: 'vehiculos'),
      Campo('motivo', 'Motivo'),
    ],
    encabezado: (r) => '${r['fecha']} · ${r['motivo']}',
    sub: (r, n) => n('vehiculos', r['vehiculoId']));

Future<void> agregarRepuesto(BuildContext ctx, WidgetRef ref, Rec orden) {
  final reps = ref.read(colProvider('repuestos')).valueOrNull ?? <Rec>[];
  String? sel;
  final cant = TextEditingController(text: '1');
  return showDialog(
    context: ctx,
    builder: (dctx) => AlertDialog(
      title: const Text('Agregar repuesto'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(
          items: [
            for (final r in reps)
              DropdownMenuItem(value: r['id'] as String, child: Text('${etiqueta(r)} (stock ${r['stock']})'))
          ],
          onChanged: (v) => sel = v,
          decoration: const InputDecoration(labelText: 'Repuesto'),
        ),
        TextField(controller: cant, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cantidad')),
      ]),
      actions: [
        FilledButton(
          onPressed: () async {
            final r = reps.where((x) => x['id'] == sel).firstOrNull;
            final n = int.tryParse(cant.text) ?? 0;
            if (r == null || n <= 0 || n > (r['stock'] as num)) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Stock insuficiente o datos inválidos')));
              return;
            }
            r['stock'] = (r['stock'] as num) - n;
            await guardar(ref, 'repuestos', r);
            orden['repuestos'] = [
              ...((orden['repuestos'] as List?) ?? []),
              {'id': r['id'], 'nombre': etiqueta(r), 'cant': n, 'precio': r['precio']}
            ];
            await guardar(ref, 'ordenes', orden);
            if (dctx.mounted) Navigator.pop(dctx);
          },
          child: const Text('Agregar'),
        ),
      ],
    ),
  );
}

// ======================= HOME =======================
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final items = <(String, IconData, Widget)>[
      ('Resumen', Icons.dashboard, const _Resumen()),
      ('Órdenes', Icons.build, CrudScreen(ordenes)),
      ('Clientes', Icons.people, CrudScreen(clientes)),
      ('Vehículos', Icons.directions_car, CrudScreen(vehiculos)),
      ('Repuestos', Icons.inventory_2, CrudScreen(repuestos)),
      ('Turnos', Icons.event, CrudScreen(turnos)),
      ('Auditoría', Icons.history, const _Auditoria()),
      ('Seguridad', Icons.security, const _Seguridad()),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(items[_i].$1)),
      drawer: Drawer(
        child: ListView(children: [
          const DrawerHeader(child: Text('Taller Mecánico', style: TextStyle(fontSize: 24))),
          for (var k = 0; k < items.length; k++)
            ListTile(
              leading: Icon(items[k].$2),
              title: Text(items[k].$1),
              selected: k == _i,
              onTap: () {
                setState(() => _i = k);
                Navigator.pop(context);
              },
            ),
        ]),
      ),
      body: items[_i].$3,
    );
  }
}

class _Resumen extends ConsumerWidget {
  const _Resumen();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Rec> g(String c) => ref.watch(colProvider(c)).valueOrNull ?? [];
    final os = g('ordenes');
    final hoy = DateTime.now().toIso8601String().substring(0, 10);
    final datos = [
      ('Órdenes abiertas', os.where((o) => o['estado'] != 'entregado').length, Icons.build),
      ('Listas para entregar', os.where((o) => o['estado'] == 'listo').length, Icons.check_circle),
      ('Repuestos con stock bajo', g('repuestos').where((r) => (r['stock'] ?? 0) <= (r['stockMinimo'] ?? 0)).length, Icons.warning),
      ('Turnos de hoy', g('turnos').where((t) => t['fecha'] == hoy).length, Icons.event),
      ('Facturado (entregadas) \$', os.where((o) => o['estado'] == 'entregado').fold<num>(0, (s, o) => s + totalOrden(o)), Icons.attach_money),
    ];
    return ListView(padding: const EdgeInsets.all(12), children: [
      for (final d in datos)
        Card(child: ListTile(leading: Icon(d.$3), title: Text(d.$1), trailing: Text('${d.$2}', style: const TextStyle(fontSize: 22)))),
    ]);
  }
}

class _Auditoria extends ConsumerWidget {
  const _Auditoria();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(auditProvider);
    if (logs.isEmpty) return const Center(child: Text('Sin eventos todavía'));
    return ListView(children: [for (final l in logs) ListTile(dense: true, leading: const Icon(Icons.article), title: Text(l))]);
  }
}

class _Seguridad extends ConsumerWidget {
  const _Seguridad();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFace = ref.watch(authProvider.select((s) => s.template != null));
    return ListView(children: [
      ListTile(
        leading: Icon(hasFace ? Icons.verified_user : Icons.face_retouching_off),
        title: Text(hasFace ? 'Biometría facial registrada' : 'Biometría facial no registrada'),
        subtitle: const Text('Toque para (re)registrar su rostro'),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaceScreen(FaceMode.enroll))),
      ),
      ListTile(leading: const Icon(Icons.logout), title: const Text('Cerrar sesión'), onTap: () => ref.read(authProvider.notifier).logout()),
    ]);
  }
}
