import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pasos del seguimiento del vehículo, en orden.
const List<String> kSteps = ['Ingresado', 'Diagnóstico', 'En reparación', 'Listo'];

/// Índice de la pestaña activa en la barra inferior (0: Inicio ... 3: Perfil).
final tabIndexProvider = StateProvider<int>((ref) => 0);

/// Paso actual del vehículo dentro de [kSteps]. Arranca en "En reparación"
/// para que la demo muestre algo de inmediato.
final vehicleStepProvider = StateProvider<int>((ref) => 2);

/// Controla si se muestra el banner de notificación ("tu auto está listo").
final showToastProvider = StateProvider<bool>((ref) => false);
