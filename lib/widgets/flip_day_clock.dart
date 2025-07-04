import 'dart:async';

import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flip_board/src/clock/flip_clock_builder.dart';
import 'package:puckin_countdown/widgets/flip_day_clock_builder.dart';

class FlipDayClock extends StatelessWidget {
  final DateTime initDuration;
  final double digitSize;
  final double width;
  final double height;
  final FlipDayClockBuilder _displayBuilder;

  FlipDayClock({
    Key? key,
    required this.initDuration,
    required this.digitSize,
    required this.width,
    required this.height,
    AxisDirection flipDirection = AxisDirection.up,
    Curve? flipCurve,
    Color? digitColor,
    Color? backgroundColor,
    double? separatorWidth,
    Color? separatorColor,
    Color? separatorBackgroundColor,
    bool? showBorder,
    double? borderWidth,
    Color? borderColor,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(4.0)),
    double hingeWidth = 0.8,
    double? hingeLength,
    Color? hingeColor,
    EdgeInsets digitSpacing = const EdgeInsets.symmetric(horizontal: 2.0),
  }) : assert(
         hingeLength == null ||
             hingeWidth == 0.0 && hingeLength == 0.0 ||
             hingeWidth > 0.0 && hingeLength > 0.0,
       ),
       assert(
         (borderWidth == null && borderColor == null) ||
             (showBorder == null || showBorder == true),
       ),
       _displayBuilder = FlipDayClockBuilder(
         digitSize: digitSize,
         width: width,
         height: height,
         flipDirection: flipDirection,
         flipCurve:
             flipCurve ??
             (flipDirection == AxisDirection.down
                 ? FlipWidget.bounceFastFlip
                 : FlipWidget.defaultFlip),
         digitColor: digitColor,
         backgroundColor: backgroundColor,
         separatorWidth: separatorWidth ?? width / 3.0,
         separatorColor: separatorColor,
         separatorBackgroundColor: separatorBackgroundColor,
         showBorder: showBorder ?? (borderColor != null || borderWidth != null),
         borderWidth: borderWidth,
         borderColor: borderColor,
         borderRadius: borderRadius,
         hingeWidth: hingeWidth,
         hingeLength: hingeWidth == 0.0
             ? 0.0
             : hingeLength ??
                   (flipDirection == AxisDirection.down ||
                           flipDirection == AxisDirection.up
                       ? width
                       : height),
         hingeColor: hingeColor,
         digitSpacing: digitSpacing,
       ),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building');
    print(initDuration);
    final now = DateTime.now();

    final periodicStream = Stream<Duration>.periodic(
      const Duration(seconds: 1),
      (_) {
        return DateTime.now().difference(initDuration);
      },
    ).asBroadcastStream();

    var duration = initDuration.difference(now);

    // final durationStream = periodicStream
    //     .takeWhile((duration) => true)
    //     .asBroadcastStream();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...[
          _buildDaysDisplay(periodicStream, duration),
          _displayBuilder.buildSeparator(context),
        ],
        _buildHoursDisplay(periodicStream, duration),
        _displayBuilder.buildSeparator(context),
        _buildMinutesDisplay(periodicStream, duration),
        _displayBuilder.buildSeparator(context),
        _buildSecondsDisplay(periodicStream, duration),
      ],
    );
  }

  Widget _buildDaysDisplay(Stream<Duration> stream, Duration initValue) =>
      _displayBuilder.buildDaysDisplay(
        stream.map((time) => time.inDays),
        initValue.inDays,
      );

  Widget _buildHoursDisplay(Stream<Duration> stream, Duration initValue) =>
      _displayBuilder.buildTimePartDisplay(
        stream.map((time) => time.inHours % 24),
        initValue.inHours % 24,
      );

  Widget _buildMinutesDisplay(Stream<Duration> stream, Duration initValue) =>
      _displayBuilder.buildTimePartDisplay(
        stream.map((time) => time.inMinutes % 60),
        initValue.inMinutes % 60,
      );

  Widget _buildSecondsDisplay(Stream<Duration> stream, Duration initValue) =>
      _displayBuilder.buildTimePartDisplay(
        stream.map((time) => time.inSeconds % 60),
        initValue.inSeconds % 60,
      );
}
