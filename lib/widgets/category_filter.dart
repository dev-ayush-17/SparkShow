import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
        children: [
          _buildCategoryChip(context, 'All'),
          ...categories.map((category) => _buildCategoryChip(context, category)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String category) {
    final isSelected = selectedCategory == category;
    final categoryColor = AppColors.categoryColors[category] ?? 
        Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.smallPadding),
      child: FilterChip(
        label: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : categoryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onCategorySelected(category),
        selectedColor: categoryColor,
        checkmarkColor: Colors.white,
        backgroundColor: categoryColor.withValues(alpha: 0.1),
        side: BorderSide(
          color: isSelected ? categoryColor : categoryColor.withValues(alpha: 0.5),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
