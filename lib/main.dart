import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_colors.dart';
import 'core/app_state.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/toast_banner.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const ProviderScope(child: TallerApp()));
}

class TallerApp extends StatelessWidget {
  const TallerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller El Motor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.orange, primary: AppColors.orange),
      ),
      home: const RootShell(),
    );
  }
}

class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  @override
  Widget build(BuildContext context) {
    final tabIndex = ref.watch(tabIndexProvider);
    final showToast = ref.watch(showToastProvider);

    // Cuando el paso del vehículo llega a "Listo", mostramos el toast
    // unos segundos y lo ocultamos solo, igual que en la beta web.
    ref.listen<int>(vehicleStepProvider, (previous, next) {
      if (next == kSteps.length - 1) {
        ref.read(showToastProvider.notifier).state = true;
        Future.delayed(const Duration(milliseconds: 3200), () {
          if (mounted) ref.read(showToastProvider.notifier).state = false;
        });
      }
    });

    const screens = [
      HomeScreen(),
      HistoryScreen(),
      AppointmentsScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _TopBar(showSubtitle: tabIndex == 0),
                Expanded(child: screens[tabIndex]),
              ],
            ),
            if (showToast)
              Positioned(
                top: 8,
                left: 12,
                right: 12,
                child: ToastBanner(
                    onClose: () =>
                        ref.read(showToastProvider.notifier).state = false),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool showSubtitle;
  const _TopBar({required this.showSubtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
                color: AppColors.orange, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Text('TM',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Taller El Motor',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.ink)),
              if (showSubtitle)
                const Text('Seguimiento de tu vehículo',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
