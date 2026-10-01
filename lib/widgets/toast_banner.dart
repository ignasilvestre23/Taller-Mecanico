import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class ToastBanner extends StatelessWidget {
  final VoidCallback onClose;
  const ToastBanner({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.charcoal,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            const Icon(Icons.notifications_rounded, color: AppColors.orange, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Tu auto está listo',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                  Text('Toyota Corolla · AB123CD te espera en recepción',
                      style: TextStyle(color: Color(0xFFC9CDD3), fontSize: 10.5)),
                ],
              ),
            ),
            GestureDetector(
              onTap: onClose,
              child: const Icon(Icons.close_rounded, color: Color(0xFFC9CDD3), size: 15),
            ),
          ],
        ),
      ),
    );
  }
}
