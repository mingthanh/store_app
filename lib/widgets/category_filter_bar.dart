import 'package:flutter/material.dart';
import 'package:store_app/utils/app_textstyles.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onChanged;
  final EdgeInsetsGeometry padding;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onChanged,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 8),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: categories.map((c) {
          final isSelected = c == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(c),
              selected: isSelected,
              onSelected: (_) => onChanged(c),
              backgroundColor: Theme.of(context).cardColor,
              selectedColor:
                  Theme.of(context).primaryColor.withAlpha((0.2 * 255).round()),
              labelStyle: AppTextStyles.withColor(
                AppTextStyles.bodyMedium,
                isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
