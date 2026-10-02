import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final String? value;
  final VoidCallback? onClear;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search fireworks…',
    required this.onChanged,
    this.value,
    this.onClear,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final hasText = widget.value != null && widget.value!.isNotEmpty;

    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _focused
                ? AppColors.primary.withValues(alpha: 0.7)
                : const Color(0x12FFFFFF), // rgba(255,255,255,0.07)
            width: _focused ? 1.5 : 1,
          ),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 10,
                    spreadRadius: 0,
                  )
                ]
              : [],
        ),
        child: TextField(
          onChanged: widget.onChanged,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: _focused ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            suffixIcon: hasText
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    onPressed: widget.onClear ?? () => widget.onChanged(''),
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
          ),
        ),
      ),
    );
  }
}
