import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_client.dart';

class ApiInfoSheet extends StatefulWidget {
  const ApiInfoSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ApiInfoSheet(),
    );
  }

  @override
  State<ApiInfoSheet> createState() => _ApiInfoSheetState();
}

class _ApiInfoSheetState extends State<ApiInfoSheet> {
  bool _testingConnection = false;
  String? _testResult;
  bool _isSuccess = false;

  Future<void> _testApiConnection() async {
    setState(() {
      _testingConnection = true;
      _testResult = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final client = ApiClient();
      await client.get(ApiEndpoints.search, queryParameters: {'q': 'hello'});
      stopwatch.stop();
      setState(() {
        _isSuccess = true;
        _testResult = 'Conexión exitosa (200 OK) en ${stopwatch.elapsedMilliseconds} ms';
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _isSuccess = false;
        _testResult = 'Error de conexión: $e';
      });
    } finally {
      setState(() {
        _testingConnection = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.api_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de la API',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'LRCLIB - Open Lyrics Database',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildInfoCard(
                  title: '¿Qué es LRCLIB?',
                  description:
                      'LRCLIB (lrclib.net) es una API pública y comunitaria diseñada para buscar y compartir letras de canciones, especialmente letras sincronizadas en formato LRC (Karaoke) y letras en texto plano.',
                  icon: Icons.info_outline_rounded,
                  color: AppColors.primary,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildEndpointsSection(isDark),
                const SizedBox(height: 12),
                _buildFeaturesSection(isDark),
                const SizedBox(height: 12),
                _buildConnectionTestCard(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointsSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.alt_route_rounded, size: 20, color: AppColors.accent),
              SizedBox(width: 8),
              Text(
                'Endpoints Consumidos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildEndpointRow('GET', '/api/search?q={query}', 'Búsqueda general de letras'),
          const Divider(height: 16),
          _buildEndpointRow('GET', '/api/search?track_name=...&artist_name=...', 'Búsqueda filtrada y detallada'),
          const Divider(height: 16),
          _buildEndpointRow('GET', '/api/get?track_name=...&artist_name=...', 'Obtener letra exacta de una canción'),
          const Divider(height: 16),
          _buildEndpointRow('GET', '/api/get/{id}', 'Consultar registro de letra por ID único'),
        ],
      ),
    );
  }

  Widget _buildEndpointRow(String method, String endpoint, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.emerald.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                method,
                style: const TextStyle(
                  color: AppColors.emerald,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                endpoint,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          desc,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection(bool isDark) {
    final features = [
      ('LRC Sincronizado', 'Marcas de tiempo [mm:ss.xx] para reproducción en vivo tipo karaoke.', Icons.timer_outlined),
      ('Texto Plano', 'Letras completas legibles para lectura directa.', Icons.text_snippet_outlined),
      ('Soporte Instrumental', 'Identifica pistas instrumentales sin contenido vocal.', Icons.music_note_outlined),
      ('Acceso Libre', 'Sin requerimiento de token o autenticación obligatoria.', Icons.lock_open_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star_outline_rounded, size: 20, color: AppColors.emerald),
              SizedBox(width: 8),
              Text(
                'Características Principales',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final f in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(f.$3, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: '${f.$1}: ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: f.$2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectionTestCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _testResult == null
              ? Colors.transparent
              : (_isSuccess ? AppColors.emerald : AppColors.error),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Estado del Servicio en Vivo',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            'Realiza un ping directo al endpoint base de lrclib.net para validar conectividad:',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          if (_testResult != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (_isSuccess ? AppColors.emerald : AppColors.error).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                    color: _isSuccess ? AppColors.emerald : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _testResult!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _isSuccess ? AppColors.emerald : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          FilledButton.icon(
            onPressed: _testingConnection ? null : _testApiConnection,
            icon: _testingConnection
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.network_check_rounded, size: 18),
            label: Text(_testingConnection ? 'Comprobando...' : 'Probar Conectividad con la API'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

