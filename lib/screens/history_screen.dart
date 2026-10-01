import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const _history = [
    {
      'date': '12 jul 2026',
      'vehicle': 'Toyota Corolla · AB123CD',
      'service': 'Cambio de aceite y filtros',
      'cost': '\$38.500',
    },
    {
      'date': '03 abr 2026',
      'vehicle': 'Toyota Corolla · AB123CD',
      'service': 'Alineación y balanceo',
      'cost': '\$21.000',
    },
    {
      'date': '19 ene 2026',
      'vehicle': 'Toyota Corolla · AB123CD',
      'service': 'Revisión de frenos',
      'cost': '\$15.200',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const Text('Historial', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.ink)),
        const SizedBox(height: 16),
        for (final h in _history)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
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
                    Expanded(
                      child: Text(h['service']!,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
                    ),
                    Text(h['cost']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(h['vehicle']!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(h['date']!, style: const TextStyle(fontSize: 11, color: AppColors.textSoft)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.greenSoft, borderRadius: BorderRadius.circular(999)),
                      child: const Text('Completado',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.greenText)),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
