import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/lyrics_search_controller.dart';

class FilterBottomSheet extends StatefulWidget {
  final LyricsSearchController controller;

  const FilterBottomSheet({super.key, required this.controller});

  static Future<void> show(BuildContext context, LyricsSearchController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(controller: controller),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late final TextEditingController _trackCtrl;
  late final TextEditingController _artistCtrl;
  late final TextEditingController _albumCtrl;
  late bool _onlySynced;

  @override
  void initState() {
    super.initState();
    _trackCtrl = TextEditingController(text: widget.controller.filterTrackName);
    _artistCtrl = TextEditingController(text: widget.controller.filterArtistName);
    _albumCtrl = TextEditingController(text: widget.controller.filterAlbumName);
    _onlySynced = widget.controller.onlySynced;
  }

  @override
  void dispose() {
    _trackCtrl.dispose();
    _artistCtrl.dispose();
    _albumCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    widget.controller.searchDetailed(
      trackName: _trackCtrl.text,
      artistName: _artistCtrl.text,
      albumName: _albumCtrl.text,
      onlySynced: _onlySynced,
    );
    Navigator.of(context).pop();
  }

  void _reset() {
    _trackCtrl.clear();
    _artistCtrl.clear();
    _albumCtrl.clear();
    setState(() {
      _onlySynced = false;
    });
    widget.controller.clearFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.filter_alt_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Búsqueda Filtrada',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Filtra por canción, artista, álbum o tipo de letra',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (widget.controller.hasActiveFilters)
                  TextButton(
                    onPressed: _reset,
                    child: const Text('Limpiar', style: TextStyle(color: AppColors.accent)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _trackCtrl,
              decoration: InputDecoration(
                labelText: 'Título de la Canción',
                hintText: 'Ej: Bohemian Rhapsody',
                prefixIcon: const Icon(Icons.music_note_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _artistCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre del Artista',
                hintText: 'Ej: Queen',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _albumCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre del Álbum (Opcional)',
                hintText: 'Ej: A Night at the Opera',
                prefixIcon: const Icon(Icons.album_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _onlySynced ? AppColors.emerald : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _onlySynced,
                  activeTrackColor: AppColors.emerald,
                  title: const Row(
                    children: [
                      Icon(Icons.sync_rounded, size: 20, color: AppColors.emerald),
                      SizedBox(width: 8),
                      Text(
                        'Solo letras sincronizadas (LRC)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    'Muestra únicamente canciones compatibles con modo karaoke',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onChanged: (val) => setState(() => _onlySynced = val),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _apply,
                    icon: const Icon(Icons.search_rounded),
                    label: const Text('Aplicar Filtro'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

