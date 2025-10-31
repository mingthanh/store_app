import 'package:flutter/material.dart';
import 'package:store_app/utils/app_textstyles.dart';

class CategoryChips extends StatefulWidget {
  // selectedIndex và onChanged cho phép cha điều khiển (controlled widget).
  // Nếu không truyền, widget sẽ tự quản lý trạng thái bên trong như trước đây.
  final int? selectedIndex; // chỉ mục chip đang chọn (0 = All)
  final ValueChanged<int>? onChanged; // callback khi người dùng chọn chip khác

  const CategoryChips({super.key, this.selectedIndex, this.onChanged});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  int selectedIndex = 0; // trạng thái nội bộ khi cha không điều khiển

  final categories = [
    'All',
    'Men',
    'Women',
    'Girls',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedIndex != null) {
      selectedIndex = widget.selectedIndex!;
    }
  }

  @override
  void didUpdateWidget(covariant CategoryChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu cha điều khiển và giá trị thay đổi thì cập nhật UI
    if (widget.selectedIndex != null && widget.selectedIndex != selectedIndex) {
      setState(() => selectedIndex = widget.selectedIndex!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          categories.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 22),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ChoiceChip(
                label: Text(
                  categories[index],
                  style: AppTextStyles.withColor(
                    selectedIndex == index
                        ? AppTextStyles.withWeight(
                            AppTextStyles.bodySmall,
                            FontWeight.w600,
                          )
                        : AppTextStyles.bodySmall,
                    selectedIndex == index
                        ? Colors.white
                        : isDark
                            ? Colors.grey[300]!
                            : Colors.grey[600]!,
                  ),
                ),
                selected: selectedIndex == index,
                onSelected: (bool selected) {
                  if (!selected) return; // chỉ xử lý khi chọn
                  // Nếu có callback từ cha, gọi callback.
                  widget.onChanged?.call(index);
                  // Khi cha không điều khiển, tự setState nội bộ.
                  if (widget.selectedIndex == null) {
                    setState(() => selectedIndex = index);
                  }
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: selectedIndex == index ? 2 : 0,
                pressElevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 1,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                  color: selectedIndex == index
                      ? Colors.transparent
                      : isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}