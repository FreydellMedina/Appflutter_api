import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/lyric.dart';
import '../controllers/favorites_controller.dart';

class LyricDetailPage extends StatefulWidget {
  final Lyric lyric;
  const LyricDetailPage({super.key, required this.lyric});

  @override
  State<LyricDetailPage> createState() => _LyricDetailPageState();
}

class _LyricDetailPageState extends State<LyricDetailPage> {
  late final List<SyncedLine> _lines;
  final ScrollController _scrollController = ScrollController();
  Duration _pos = Duration.zero;
  bool _playing = false;
  Timer? _timer;
  int _activeLineIndex = -1;
  bool _showSyncedView = true;

  @override
  void initState() {
    super.initState();
    _lines = Helpers.parseLrc(widget.lyric.syncedLyrics);
    _showSyncedView = _lines.isNotEmpty;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _playing = !_playing);
    if (_playing) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        setState(() {
          _pos += const Duration(milliseconds: 100);
          _updateActiveIndex();
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  void _updateActiveIndex() {
    int newIndex = -1;
    for (int i = 0; i < _lines.length; i++) {
      final isLast = i == _lines.length - 1;
      if (_pos >= _lines[i].timestamp && (isLast || _pos < _lines[i + 1].timestamp)) {
        newIndex = i;
        break;
      }
    }
    if (newIndex != _activeLineIndex && newIndex != -1) {
      _activeLineIndex = newIndex;
      _scrollToActiveLine();
    }
  }

  void _scrollToActiveLine() {
    if (_scrollController.hasClients && _activeLineIndex >= 0) {
      final targetOffset = (_activeLineIndex * 60.0).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _seekTo(Duration duration) {
    setState(() {
      _pos = duration;
      _updateActiveIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favoritesController = context.watch<FavoritesController?>();
    final isFav = favoritesController?.isFavorite(widget.lyric.id) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lyric.trackName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (favoritesController != null)
            IconButton(
              icon: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? AppColors.accent : null,
              ),
              tooltip: isFav ? 'Quitar de favoritos' : 'Guardar en favoritos',
              onPressed: () {
                favoritesController.toggleFavorite(widget.lyric);
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      isFav ? 'Eliminado de favoritos' : 'Agregado a favoritos',
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSongHeader(isDark),
          if (_lines.isNotEmpty && widget.lyric.plainLyrics != null && widget.lyric.plainLyrics!.isNotEmpty)
            _buildViewToggle(isDark),
          Expanded(
            child: _buildBodyContent(isDark),
          ),
        ],
      ),
      floatingActionButton: (_lines.isNotEmpty && _showSyncedView)
          ? FloatingActionButton.extended(
              onPressed: _togglePlay,
              icon: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
              label: Text(_playing ? 'Pausar Karaoke' : 'Simular Karaoke'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _buildSongHeader(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.lyric.trackName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.lyric.artistName,
            style: const TextStyle(fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
          if (widget.lyric.albumName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Álbum: ${widget.lyric.albumName}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (widget.lyric.duration > 0)
                _buildBadge(
                  Icons.timer_outlined,
                  Helpers.formatDuration(widget.lyric.duration),
                  Colors.blueGrey,
                ),
              if (widget.lyric.hasSyncedLyrics)
                _buildBadge(Icons.sync_rounded, 'LRC Sincronizado', AppColors.emerald),
              if (widget.lyric.plainLyrics != null && widget.lyric.plainLyrics!.isNotEmpty)
                _buildBadge(Icons.text_snippet_outlined, 'Texto Plano', AppColors.primary),
              if (widget.lyric.instrumental)
                _buildBadge(Icons.piano_rounded, 'Instrumental', AppColors.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              label: const Center(child: Text('Karaoke Sincronizado')),
              selected: _showSyncedView,
              onSelected: (val) {
                if (val) setState(() => _showSyncedView = true);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ChoiceChip(
              label: const Center(child: Text('Texto Completo')),
              selected: !_showSyncedView,
              onSelected: (val) {
                if (val) setState(() => _showSyncedView = false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(bool isDark) {
    if (widget.lyric.instrumental) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_off_rounded, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Pista Instrumental',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta pieza es instrumental y no contiene letra vocal registrada.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_showSyncedView && _lines.isNotEmpty) {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 90, left: 16, right: 16),
        itemCount: _lines.length,
        itemBuilder: (context, i) {
          final isCurrent = i == _activeLineIndex;
          return InkWell(
            onTap: () => _seekTo(_lines[i].timestamp),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.primary.withOpacity(0.18)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isCurrent
                    ? Border.all(color: AppColors.primary.withOpacity(0.5))
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    Helpers.formatDuration(_lines[i].timestamp.inSeconds.toDouble()),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: isCurrent ? AppColors.primary : Colors.grey,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _lines[i].text.isEmpty ? '♪ ♪ ♪' : _lines[i].text,
                      style: TextStyle(
                        fontSize: isCurrent ? 17 : 14,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent
                            ? (isDark ? Colors.white : AppColors.primaryDark)
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Fallback: Plain lyrics
    final plain = widget.lyric.plainLyrics;
    if (plain != null && plain.trim().isNotEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SelectableText(
          plain,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            letterSpacing: 0.3,
          ),
        ),
      );
    }

    // No lyrics available
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lyrics_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 14),
          Text(
            'Sin letra disponible',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'No se encontraron registros de letra para esta versión.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}