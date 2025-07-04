import 'dart:convert';
import 'package:flutter/widgets.dart';

class TeamData {
  String name;
  DateTime founded;
  DateTime? lastStanleyCup;
  Image teamLogo;

  TeamData({
    required this.name,
    required this.founded,
    this.lastStanleyCup,
    required this.teamLogo,
  });

  factory TeamData.fromJson(Map<String, dynamic> json) {
    // final base64str = json["logo_base64"].split(',').last;
    return TeamData(
      name: json["team"],
      founded: DateTime.parse(json["founded"]),
      lastStanleyCup: json["last_stanley_cup"] == null
          ? null
          : DateTime.parse(json["last_stanley_cup"]),
      teamLogo: Image.memory(base64Decode(json["logo_base64"])),
    );
  }
}
