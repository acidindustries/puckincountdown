import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puckin_countdown/app_icon.dart';
import 'package:puckin_countdown/cup_troller.dart';
import 'package:puckin_countdown/team_data.dart';
import 'package:share_plus/share_plus.dart';
import 'package:web/web.dart' as web hide Text;
import 'package:web/web.dart' hide Text, Animation;

void main() {
  runApp(PuckinCountdownApp());
}

class PuckinCountdownApp extends StatelessWidget {
  PuckinCountdownApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Puckin' Countdown - Stanley Cup Drought Tracker",
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.white,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
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
  late String _selectedTeam;
  String _countdownText = '';
  late DateTime _lastDate = DateTime.now();
  String _trollMessage = '';
  bool _showFront = true;

  Map<String, TeamData> nhlTeamsData = {};
  Map<String, dynamic> cupWins = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = Uri.parse(web.window.location.href);
    if (nhlTeamsData.isEmpty) {
      _selectedTeam = 'UNK';
    } else {
      final random = Random();
      _selectedTeam = uri.queryParameters['team'] == null
          ? nhlTeamsData[nhlTeamsData.keys.elementAt(
                  random.nextInt(nhlTeamsData.length),
                )]!
                .name
          : uri.queryParameters['team'] as String;
      if (nhlTeamsData.isEmpty || !nhlTeamsData.keys.contains(_selectedTeam)) {
        _selectedTeam = 'UNK';
      }
    }
    _loadDateAndMessage();
  }

  @override
  void initState() {
    super.initState();
    _loadJsonData().then((_) {
      CupTroller.loadTrollMessages().then((_) {
        _loadDateAndMessage();
      });
    });

    _startTimer();
  }

  void _loadDateAndMessage() {
    final teamData = nhlTeamsData[_selectedTeam];
    DateTime date;
    if (teamData == null) return;

    if (teamData.lastStanleyCup == null) {
      date = teamData.founded;
    } else {
      date = teamData.lastStanleyCup!;
    }

    setState(() {
      _lastDate = date;
      print(_lastDate);
      _trollMessage = CupTroller.getTrollMessage(
        _selectedTeam,
        DateTime.now().difference(_lastDate),
      );
    });
    _updateUri(_selectedTeam);
  }

  _loadJsonData() async {
    String data = await rootBundle.loadString('assets/data.json');
    final decoded = jsonDecode(data) as Map<String, dynamic>;
    nhlTeamsData = (decoded["nhl_teams"] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, TeamData.fromJson(value)),
    );
    cupWins = (decoded["cups_wins"] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, List<int>.from(value)),
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
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final difference = now.difference(_lastDate);

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    _countdownText =
        '${days.toString().padLeft(3, '0')} days ${hours.toString().padLeft(2, '0')} hours ${minutes.toString().padLeft(2, '0')} minutes and ${seconds.toString().padLeft(2, '0')} seconds';
  }

  @override
  Widget build(BuildContext context) {
    final selectedTeamData = nhlTeamsData[_selectedTeam];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stanley Cup Drought Tracker',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        centerTitle: true,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTeam == 'UNK'
                  ? nhlTeamsData.keys.first
                  : _selectedTeam,
              dropdownColor: Theme.of(context).colorScheme.secondaryContainer,
              iconEnabledColor: Theme.of(
                context,
              ).colorScheme.secondaryContainer,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 18,
              ),
              // icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              padding: EdgeInsets.all(12),
              items: nhlTeamsData.keys.where((key) => key != 'UNK').map((
                String teamCode,
              ) {
                return DropdownMenuItem<String>(
                  value: teamCode,
                  child: Text(
                    '${nhlTeamsData[teamCode]!.name} ($teamCode)',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue == null) {
                  return;
                }
                _selectedTeam = newValue;
                _showFront = true;
                _loadDateAndMessage();
                _updateUri(newValue);
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
                Text(
                  selectedTeamData?.name ?? "Parts Unknown Unknowns",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                // const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => setState(() => _showFront = !_showFront),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 400),
                    transitionBuilder: _flipTransition,
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    layoutBuilder: (widget, list) =>
                        Stack(children: [if (widget != null) widget, ...list]),
                    child:
                        (_showFront
                                ? _buildFrontCard(selectedTeamData)
                                : _buildBackCard(selectedTeamData))
                            as Widget,
                  ),
                ),
                Spacer(),
                // const SizedBox(height: 30),
                Column(
                  children: [
                    if (_selectedTeam != 'UNK')
                      Text(
                        "❄️ Stanley Cup Drought",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    if (_selectedTeam != 'UNK')
                      Text(
                        _countdownText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    if (_selectedTeam != 'UNK')
                      Text(
                        'Last cup won: ${selectedTeamData?.lastStanleyCup?.year ?? 'never'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                  ],
                ),
                // const SizedBox(height: 30),
                if (_selectedTeam != 'UNK') Spacer(),
                // Troll message
                if (_selectedTeam != 'UNK')
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade500),
                    ),
                    child: Text(
                      _trollMessage,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.red.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_selectedTeam != 'UNK') Spacer(),
                if (_selectedTeam != 'UNK')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () async {
                      try {
                        var result = await SharePlus.instance.share(
                          ShareParams(
                            subject:
                                "${nhlTeamsData[_selectedTeam]!.name} Stanley Cup Drought Calculator",
                            // text: _countdownText,
                            uri: Uri.parse(web.window.location.href),
                          ),
                        );
                      } catch (e) {
                        debugPrint("Share error: $e");
                      }
                    },
                    child: Text('Share the Roast'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateUri(String teamAccronym) {
    final currentUri = Uri.parse(web.window.location.href);
    final queryParameters = Map<String, String>.from(
      currentUri.queryParameters,
    );
    queryParameters['team'] = teamAccronym;
    final newUri = currentUri.replace(queryParameters: queryParameters);
    web.window.history.pushState(null, '', newUri.toString());
  }

  Widget _flipTransition(Widget child, Animation<double> animation) {
    final rotate = Tween(begin: pi, end: 0.0).animate(animation);

    return AnimatedBuilder(
      animation: rotate,
      child: child,
      builder: (context, child) {
        final isUnder = (child!.key != ValueKey(_showFront));
        final rotateY = isUnder ? pi - rotate.value : rotate.value;
        return Transform(
          transform: Matrix4.rotationY(rotateY),
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }

  Widget _buildFrontCard(TeamData? selectedTeamData) {
    return Card(
      key: ValueKey(true),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            selectedTeamData != null
                ? Image(
                    image: selectedTeamData.teamLogo.image,
                    height: 400,
                    width: 400,
                  )
                : CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackCard(TeamData? selectedTeamData) {
    return Card(
      key: ValueKey(false),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 400,
          height: 400,
          child: Column(
            children: [
              Text(
                "🏆 Stanley Cup Wins",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    cupWins[_selectedTeam] == null ||
                        cupWins[_selectedTeam].isEmpty
                    ? [
                        SizedBox(
                          height: 250,
                          width: 250,
                          child: Text(
                            '🤣',
                            style: TextStyle(fontSize: 164),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ]
                    : cupWins[_selectedTeam].map<Chip>((int year) {
                            return Chip(label: Text(year.toString()));
                          }).toList()
                          as List<Chip>,
              ),
              const Spacer(),
              Text(
                "Tap again to go back",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
