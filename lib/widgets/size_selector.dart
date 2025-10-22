import 'package:flutter/material.dart';

class SizeSelector extends StatefulWidget {
  const SizeSelector({super.key});

  @override
  State<SizeSelector> createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<SizeSelector> {
  int selectedSize = 0;
  final sizes = ['36', '37', '38', '39', '40'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: List.generate(
        sizes.length,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(
              sizes[index],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selectedSize == index
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            selected: selectedSize == index,
            onSelected: (bool selected) {
              setState(() {
                selectedSize = selected ? index : selectedSize;
              });
            },
            selectedColor: Theme.of(context).primaryColor,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selectedSize == index
                    ? Theme.of(context).primaryColor
                    : (isDark ? Colors.white38 : Colors.grey),
              ),
            ),
            elevation: selectedSize == index ? 4 : 0,
            pressElevation: 2,
          ),
        ),
      ),
    );
  }
}
