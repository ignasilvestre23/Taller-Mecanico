import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_state.dart';

class StatusStepper extends StatelessWidget {
  final int currentStep;
  const StatusStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < kSteps.length; i++) ...[
          _StepDot(label: kSteps[i], done: i < currentStep, active: i == currentStep),
          if (i != kSteps.length - 1)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                height: 2,
                color: i < currentStep ? AppColors.orange : AppColors.line,
              ),
            ),
        ],
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  const _StepDot({required this.label, required this.done, required this.active});

  @override
  Widget build(BuildContext context) {
    final highlighted = done || active;
    return SizedBox(
      width: 62,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: active ? 30 : 24,
            height: active ? 30 : 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlighted ? AppColors.orange : Colors.white,
              border: Border.all(color: highlighted ? AppColors.orange : AppColors.line, width: 2),
              boxShadow: active
                  ? [BoxShadow(color: AppColors.orangeSoft, blurRadius: 0, spreadRadius: 5)]
                  : const [],
            ),
            alignment: Alignment.center,
            child: done
                ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                : active
                    ? Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      )
                    : Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: AppColors.textSoft, shape: BoxShape.circle),
                      ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: highlighted ? AppColors.ink : AppColors.textSoft,
            ),
          ),
        ],
      ),
    );
  }
}
