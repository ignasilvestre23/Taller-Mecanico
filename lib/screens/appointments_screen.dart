import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const Text('Turnos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.ink)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.orangeSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.orange),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Próximo turno', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.orangeText)),
              SizedBox(height: 4),
              Text('Service de los 40.000 km',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
              Text('Miércoles 26 de agosto · 10:00', style: TextStyle(fontSize: 11, color: AppColors.orangeText)),
            ],
          ),
        ),

        const SizedBox(height: 20),
        const Text('Solicitar nuevo turno',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
        const SizedBox(height: 10),

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
              const Text('VEHÍCULO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
                child: const Text('Toyota Corolla · AB123CD', style: TextStyle(fontSize: 12, color: AppColors.ink)),
              ),
              const SizedBox(height: 12),
              const Text('MOTIVO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)),
                child: const Text('Ej: ruido en freno delantero', style: TextStyle(fontSize: 12, color: AppColors.textSoft)),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                  label: const Text('Solicitar turno',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
