import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/app_state.dart';

class AppBottomNavBar extends ConsumerWidget {
  const AppBottomNavBar({super.key});

  static const _items = [
    (Icons.home_rounded, 'Inicio'),
    (Icons.access_time_rounded, 'Historial'),
    (Icons.calendar_month_rounded, 'Turnos'),
    (Icons.person_rounded, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final active = i == index;
          final (icon, label) = _items[i];
          return GestureDetector(
            onTap: () => ref.read(tabIndexProvider.notifier).state = i,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: active ? AppColors.orange : AppColors.textSoft),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: active ? AppColors.orange : AppColors.textSoft,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
