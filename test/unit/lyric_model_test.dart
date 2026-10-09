import 'package:flutter_test/flutter_test.dart';
import 'package:lrc_finder/features/lyrics_search/data/models/lyric_model.dart';
import 'package:lrc_finder/features/lyrics_search/domain/entities/lyric.dart';

void main() {
  group('LyricModel Tests - Serialización y Deserialización de Respuestas', () {
    test('Debe deserializar correctamente un JSON completo con letras sincronizadas', () {
      final json = {
        'id': 101,
        'name': 'Get Lucky',
        'trackName': 'Get Lucky',
        'artistName': 'Daft Punk',
        'albumName': 'Random Access Memories',
        'duration': 369.5,
        'instrumental': false,
        'plainLyrics': 'Like the legend of the phoenix...',
        'syncedLyrics': '[00:20.10] Like the legend of the phoenix\n[00:24.00] All ends with beginnings',
      };

      final model = LyricModel.fromJson(json);

      expect(model.id, 101);
      expect(model.trackName, 'Get Lucky');
      expect(model.artistName, 'Daft Punk');
      expect(model.albumName, 'Random Access Memories');
      expect(model.duration, 369.5);
      expect(model.instrumental, false);
      expect(model.hasSyncedLyrics, true);
      expect(model.hasLyrics, true);
      expect(model.plainLyrics, isNotNull);
    });

    test('Debe soportar pistas instrumentales sin letras', () {
      final json = {
        'id': 202,
        'name': 'Orion',
        'trackName': 'Orion',
        'artistName': 'Metallica',
        'albumName': 'Master of Puppets',
        'duration': 507.0,
        'instrumental': true,
        'plainLyrics': null,
        'syncedLyrics': null,
      };

      final model = LyricModel.fromJson(json);

      expect(model.id, 202);
      expect(model.instrumental, true);
      expect(model.hasSyncedLyrics, false);
      expect(model.hasLyrics, false);
    });

    test('Debe usar valores por defecto seguros cuando faltan campos o son nulos', () {
      final json = <String, dynamic>{
        'id': '303', // Id como String
      };

      final model = LyricModel.fromJson(json);

      expect(model.id, 303);
      expect(model.trackName, 'Desconocido');
      expect(model.artistName, 'Artista Desconocido');
      expect(model.albumName, '');
      expect(model.duration, 0.0);
      expect(model.instrumental, false);
      expect(model.plainLyrics, isNull);
      expect(model.syncedLyrics, isNull);
    });

    test('Debe serializar de vuelta a Map (toJson) manteniendo los datos', () {
      const entity = Lyric(
        id: 55,
        name: 'Clocks',
        trackName: 'Clocks',
        artistName: 'Coldplay',
        albumName: 'A Rush of Blood to the Head',
        duration: 307.0,
        instrumental: false,
        plainLyrics: 'Lights go out and I can\'t be saved',
        syncedLyrics: '[00:30.00] Lights go out and I can\'t be saved',
      );

      final model = LyricModel.fromEntity(entity);
      final json = model.toJson();

      expect(json['id'], 55);
      expect(json['trackName'], 'Clocks');
      expect(json['artistName'], 'Coldplay');
      expect(json['duration'], 307.0);
      expect(json['plainLyrics'], 'Lights go out and I can\'t be saved');
    });
  });
}

