import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puckin_countdown/team_data.dart';
import 'package:puckin_countdown/widgets/flip_day_clock.dart';
import 'package:web/web.dart' as web hide Text;

void main() {
  runApp(const PuckinCountdownApp());
}

class PuckinCountdownApp extends StatelessWidget {
  const PuckinCountdownApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Puckin' Countdown",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xff1a365d),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff2d3748),
          foregroundColor: Colors.white,
        ),
      ),
      home: const CountdownScreen(),
    );
  }
}

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  Timer? _timer;
  late String _selectedTeam = 'TOR';
  String _countdownText = '';

  Map<String, TeamData> nhlTeamsData = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = Uri.parse(web.window.location.href);
    _selectedTeam = uri.queryParameters['team'] == null
        ? 'MTL'
        : uri.queryParameters['team'] as String;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadJsonData();
    });

    _startTimer();
  }

  _loadJsonData() async {
    String data = await rootBundle.loadString('assets/data.json');
    final decoded = jsonDecode(data) as Map<String, dynamic>;
    nhlTeamsData = (decoded["nhl_teams"] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, TeamData.fromJson(value)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _updateCountdown();
      });
    });
    _updateCountdown();
  }

  void _updateCountdown() {
    final teamData = nhlTeamsData[_selectedTeam];
    DateTime date;
    if (teamData == null) return;

    if (teamData.lastStanleyCup == null) {
      date = teamData.founded;
    } else {
      date = teamData.lastStanleyCup!;
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    _countdownText =
        '${days.toString().padLeft(3, '0')}:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final selectedTeamData = nhlTeamsData[_selectedTeam];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Puckin\' Countdown'),
        centerTitle: true,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTeam,
              dropdownColor: const Color(0xff2d3748),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              padding: EdgeInsets.all(12),
              items: nhlTeamsData.keys.map((String teamCode) {
                return DropdownMenuItem<String>(
                  value: teamCode,
                  child: Text(
                    '${nhlTeamsData[teamCode]!.name} ($teamCode)',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue == null) {
                  return;
                }

                _selectedTeam = newValue;
                _updateCountdown();
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Team Information
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 1,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Team Name
                      // Text(
                      //   selectedTeamData!.name,
                      //   style: const TextStyle(
                      //     fontSize: 24,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.white,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                      // Team Logo
                      Image(
                        image: selectedTeamData!.teamLogo.image,
                        width: 400,
                        height: 400,
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Text(
                  selectedTeamData.lastStanleyCup == null
                      ? "The ${selectedTeamData.name} have never won the Stanley cup!"
                      : "The ${selectedTeamData.name} have not won the Stanley cup since",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withAlpha(120),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff1a365d),
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: FlipDayClock(
                    initDuration:
                        nhlTeamsData[_selectedTeam]!.lastStanleyCup ??
                        nhlTeamsData[_selectedTeam]!.founded,
                    digitSize: 54.0,
                    width: 46.0,
                    height: 62.0,
                    separatorColor: Colors.black,
                    hingeColor: Colors.black,
                    digitColor: Colors.black,
                    separatorBackgroundColor: Colors.white,
                    backgroundColor: Colors.white,
                    showBorder: true,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getFunFact(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFunFact() {
    final teamData = nhlTeamsData[_selectedTeam];
    if (teamData!.lastStanleyCup == null) {
      return 'Keep cheering. Every team\'s journey to their first Stanley Cup is special!';
    }

    final yearsSince =
        DateTime.now().difference(teamData.lastStanleyCup!).inDays ~/ 365;
    if (yearsSince < 2) {
      return 'Recent champions! The Cup is still shiny! ✨';
    } else if (yearsSince < 5) {
      return 'Still basking in recent glory! 🌟';
    } else if (yearsSince < 10) {
      return 'Time to start another Cup run! 🚀';
    } else if (yearsSince < 20) {
      return 'The drought is getting real... 🏜️';
    } else {
      return 'Legendary patience! The next Cup will be extra sweet! 🙏';
    }
  }
}
