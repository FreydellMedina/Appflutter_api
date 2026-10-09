class SyncedLine {
  final Duration timestamp;
  final String text;

  const SyncedLine({required this.timestamp, required this.text});
}

class Helpers {
  Helpers._();

  static String formatDuration(double? seconds) {
    if (seconds == null || seconds <= 0) return '--:--';
    final int totalSec = seconds.round();
    final int minutes = totalSec ~/ 60;
    final int remainingSec = totalSec % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSec.toString().padLeft(2, '0')}';
  }

  static List<SyncedLine> parseLrc(String? lrcText) {
    if (lrcText == null || lrcText.trim().isEmpty) return [];
    final List<SyncedLine> lines = [];
    final RegExp regExp = RegExp(r'\[(\d{2}):(\d{2})\.?(\d{2,3})?\](.*)');

    for (final rawLine in lrcText.split('\n')) {
      final match = regExp.firstMatch(rawLine.trim());
      if (match != null) {
        final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
        final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;
        final msStr = match.group(3) ?? '0';
        final ms = msStr.length == 2 ? (int.tryParse(msStr) ?? 0) * 10 : (int.tryParse(msStr) ?? 0);
        final duration = Duration(minutes: minutes, seconds: seconds, milliseconds: ms);
        lines.add(SyncedLine(timestamp: duration, text: (match.group(4) ?? '').trim()));
      }
    }
    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return lines;
  }
}