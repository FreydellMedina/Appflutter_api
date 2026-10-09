import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/favorites_controller.dart';
import '../controllers/lyrics_search_controller.dart';
import '../widgets/api_info_sheet.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/lyric_card.dart';
import '../widgets/search_bar_widget.dart';
import 'lyric_detail_page.dart';

class LyricsSearchPage extends StatefulWidget {
  const LyricsSearchPage({super.key});

  @override
  State<LyricsSearchPage> createState() => _LyricsSearchPageState();
}

class _LyricsSearchPageState extends State<LyricsSearchPage> {
  late final TextEditingController _searchCtrl;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onQuickSearch(String text, LyricsSearchController controller) {
    _searchCtrl.text = text;
    controller.search(text);
  }

  @override
  Widget build(BuildContext context) {
    final searchController = context.watch<LyricsSearchController>();
    final favoritesController = context.watch<FavoritesController?>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.queue_music_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('LRCLIB Finder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Información de la API',
            onPressed: () => ApiInfoSheet.show(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _buildSearchTab(context, searchController, isDark),
          _buildFavoritesTab(context, favoritesController, isDark),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) => setState(() => _selectedTabIndex = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.search_rounded, color: AppColors.primary),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: (favoritesController?.favorites.length ?? 0) > 0,
              label: Text('${favoritesController?.favorites.length ?? 0}'),
              child: const Icon(Icons.favorite_border_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: (favoritesController?.favorites.length ?? 0) > 0,
              label: Text('${favoritesController?.favorites.length ?? 0}'),
              child: const Icon(Icons.favorite_rounded, color: AppColors.accent),
            ),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab(
    BuildContext context,
    LyricsSearchController controller,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          SearchBarWidget(
            controller: _searchCtrl,
            onSubmitted: (q) => controller.search(q),
            onClear: () {
              _searchCtrl.clear();
              controller.search('');
            },
            onToggleFilters: () => FilterBottomSheet.show(context, controller),
            isFilterActive: controller.hasActiveFilters,
            activeFilterCount: controller.activeFilterCount,
          ),
          if (controller.hasActiveFilters) ...[
            const SizedBox(height: 10),
            _buildActiveFiltersBanner(controller, isDark),
          ],
          const SizedBox(height: 12),
          Expanded(child: _buildSearchContent(context, controller, isDark)),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersBanner(LyricsSearchController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (controller.filterTrackName.isNotEmpty)
                  _buildFilterChip('Canción: "${controller.filterTrackName}"'),
                if (controller.filterArtistName.isNotEmpty)
                  _buildFilterChip('Artista: "${controller.filterArtistName}"'),
                if (controller.filterAlbumName.isNotEmpty)
                  _buildFilterChip('Álbum: "${controller.filterAlbumName}"'),
                if (controller.onlySynced)
                  _buildFilterChip('Solo SYNC'),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.accent),
            tooltip: 'Quitar filtros',
            onPressed: () {
              controller.clearFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  Widget _buildSearchContent(
    BuildContext context,
    LyricsSearchController controller,
    bool isDark,
  ) {
    switch (controller.status) {
      case LyricsSearchStatus.initial:
        return _buildInitialView(controller, isDark);
      case LyricsSearchStatus.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Buscando letras en LRCLIB...',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        );
      case LyricsSearchStatus.empty:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'No se encontraron letras',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'No encontramos resultados para "${controller.currentQuery}". Verifica la ortografía o intenta con la búsqueda filtrada.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => FilterBottomSheet.show(context, controller),
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Probar Búsqueda Filtrada'),
                ),
              ],
            ),
          ),
        );
      case LyricsSearchStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.error),
                const SizedBox(height: 16),
                const Text(
                  'Ocurrió un inconveniente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage ?? 'Error desconocido al consultar el servicio.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => controller.search(_searchCtrl.text),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
          ),
        );
      case LyricsSearchStatus.loaded:
        return ListView.builder(
          itemCount: controller.lyrics.length,
          itemBuilder: (context, i) {
            final lyric = controller.lyrics[i];
            return LyricCard(
              lyric: lyric,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LyricDetailPage(lyric: lyric)),
                );
              },
            );
          },
        );
    }
  }

  Widget _buildInitialView(LyricsSearchController controller, bool isDark) {
    final suggestions = ['Bohemian Rhapsody', 'Imagine Dragons', 'Coldplay - Yellow', 'Daft Punk', 'Adele'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headphones_rounded, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Encuentra letras sincronizadas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Escribe el nombre de cualquier canción o artista para explorar letras en tiempo real (LRC) y texto plano.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Búsquedas sugeridas:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: suggestions.map((query) {
              return ActionChip(
                label: Text(query),
                avatar: const Icon(Icons.music_note_rounded, size: 16),
                onPressed: () => _onQuickSearch(query, controller),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab(
    BuildContext context,
    FavoritesController? controller,
    bool isDark,
  ) {
    if (controller == null || controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final favorites = controller.favorites;

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_border_rounded, size: 52, color: AppColors.accent),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin favoritos guardados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Guarda tus canciones favoritas tocando el ícono de corazón en cualquier resultado de búsqueda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => setState(() => _selectedTabIndex = 0),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Ir a Buscar'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                '${favorites.length} Cancion${favorites.length == 1 ? 'es' : 'es'} guardada${favorites.length == 1 ? '' : 's'}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, i) {
                final lyric = favorites[i];
                return LyricCard(
                  lyric: lyric,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LyricDetailPage(lyric: lyric)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}