import 'package:festum/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DynamicSelectionList extends StatelessWidget {
  final String title;
  final Map<String, bool> items;
  final Function(String) onToggle;

  const DynamicSelectionList({
    super.key,
    required this.title,
    required this.items,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.entries.map((entry) {
            final isSelected = entry.value;
            return InkWell(
              onTap: () => onToggle(entry.key),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.appBar.withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.appBar : Colors.black12,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.add_circle_outline,
                      size: 18,
                      color: isSelected ? AppColors.appBar : AppColors.secondaryText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? AppColors.appBar : AppColors.secondaryText,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
