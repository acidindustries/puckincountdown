import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

class CupTroller {
  static Map<String, dynamic>? _trolls;

  static Future<void> loadTrollMessages() async {
    final json = await rootBundle.loadString('assets/trolls.json');
    _trolls = jsonDecode(json);
  }

  static String getTrollMessage(String team, Duration? lastWin) {
    if (_trolls == null) {
      return 'Troll messages not loaded.';
    }

    final random = Random();
    final teamMessages = _trolls!['teams'][team] as List<dynamic>?;
    final neverWon = lastWin == null;

    if (neverWon) {
      if (teamMessages != null && teamMessages.isNotEmpty) {
        return teamMessages[random.nextInt(teamMessages.length)];
      }
      final neverWonMessages =
          _trolls!['thresholds']['never_won'] as List<dynamic>;
      return neverWonMessages[random.nextInt(neverWonMessages.length)];
    }

    if (teamMessages != null && teamMessages.isNotEmpty) {
      return teamMessages[random.nextInt(teamMessages.length)];
    }

    final yearsSince = (lastWin.inDays / 365).floor();

    final threshold = switch (yearsSince) {
      <= 5 => 'fresh',
      <= 10 => '10_years',
      <= 20 => '20_years',
      <= 30 => '30_years',
      _ => '50_years',
    };

    final thresholdMessages =
        _trolls!['thresholds'][threshold] as List<dynamic>;
    return thresholdMessages[random.nextInt(thresholdMessages.length)];
  }
}
