import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_state.dart';
import '../widgets/status_stepper.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(vehicleStepProvider);
    final ready = step == kSteps.length - 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const Text('Hola, Martín 👋',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.ink)),
        const SizedBox(height: 16),

        // Tarjeta del vehículo activo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.directions_car_rounded, size: 18, color: AppColors.ink),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Toyota Corolla 2019',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                          Text('Patente AB123CD', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ready ? AppColors.greenSoft : AppColors.orangeSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      ready ? 'Listo' : 'En curso',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: ready ? AppColors.greenText : AppColors.orangeText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              StatusStepper(currentStep: step),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(top: 14),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
                child: ready
                    ? const Text('🎉 Tu auto está listo para retirar. Te esperamos hasta las 19:00.',
                        style: TextStyle(fontSize: 12, color: AppColors.greenText))
                    : RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          children: [
                            TextSpan(text: 'Estimado de entrega: '),
                            TextSpan(
                                text: 'hoy, 18:00',
                                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink)),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Controles de demo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.textSoft),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Controles de prueba (beta)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ),
              _SmallButton(label: 'Reiniciar', filled: false, onTap: () => ref.read(vehicleStepProvider.notifier).state = 0),
              const SizedBox(width: 8),
              _SmallButton(
                label: 'Simular avance',
                filled: true,
                onTap: ready ? null : () => ref.read(vehicleStepProvider.notifier).state = step + 1,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Text('Accesos rápidos', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(child: _QuickAction(icon: Icons.calendar_month_rounded, label: 'Agendar')),
            SizedBox(width: 10),
            Expanded(child: _QuickAction(icon: Icons.access_time_rounded, label: 'Historial')),
            SizedBox(width: 10),
            Expanded(child: _QuickAction(icon: Icons.call_rounded, label: 'Contactar')),
          ],
        ),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.charcoal, borderRadius: BorderRadius.circular(16)),
          child: const Row(
            children: [
              Icon(Icons.location_on_rounded, color: AppColors.orange, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Taller El Motor',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text('Av. Siempre Viva 1234 · Lun a Sáb 8-19h',
                        style: TextStyle(fontSize: 11, color: Color(0xFFC9CDD3))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback? onTap;
  const _SmallButton({required this.label, required this.filled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: filled ? AppColors.orange : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: filled ? null : Border.all(color: AppColors.line),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: filled ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.orange),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.ink)),
        ],
      ),
    );
  }
}
