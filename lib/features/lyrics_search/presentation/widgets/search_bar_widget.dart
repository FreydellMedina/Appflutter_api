import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback? onToggleFilters;
  final bool isFilterActive;
  final int activeFilterCount;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
    this.onToggleFilters,
    this.isFilterActive = false,
    this.activeFilterCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFilterActive
              ? AppColors.primary
              : (isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
          width: isFilterActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isFilterActive
                ? AppColors.primary.withOpacity(0.15)
                : Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.primary),
            tooltip: 'Buscar',
            onPressed: () => onSubmitted(controller.text),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Buscar canción, artista o letra...',
                hintStyle: TextStyle(fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 14),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              tooltip: 'Limpiar texto',
              onPressed: onClear,
            ),
          if (onToggleFilters != null)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.tune_rounded,
                    color: isFilterActive ? AppColors.primary : null,
                  ),
                  tooltip: 'Filtros de búsqueda',
                  onPressed: onToggleFilters,
                ),
                if (isFilterActive && activeFilterCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$activeFilterCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}