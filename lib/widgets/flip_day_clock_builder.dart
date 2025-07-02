import 'dart:math';

import 'package:flip_board/flip_widget.dart';
import 'package:flip_board/src/clock/flip_clock_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class FlipDayClockBuilder extends FlipClockBuilder {
  const FlipDayClockBuilder({
    required double digitSize,
    required double width,
    required double height,
    required AxisDirection flipDirection,
    Curve? flipCurve,
    Color? digitColor,
    Color? backgroundColor,
    required double separatorWidth,
    Color? separatorColor,
    Color? separatorBackgroundColor,
    required bool showBorder,
    double? borderWidth,
    Color? borderColor,
    required BorderRadius borderRadius,
    required double hingeWidth,
    required double hingeLength,
    Color? hingeColor,
    required EdgeInsets digitSpacing,
  }) : super(
         digitSize: digitSize,
         width: width,
         height: height,
         flipDirection: flipDirection,
         flipCurve: flipCurve,
         digitColor: digitColor,
         backgroundColor: backgroundColor,
         separatorWidth: separatorWidth,
         separatorColor: separatorColor,
         separatorBackgroundColor: separatorBackgroundColor,
         showBorder: showBorder,
         borderWidth: borderWidth,
         borderColor: borderColor,
         borderRadius: borderRadius,
         hingeWidth: hingeWidth,
         hingeLength: hingeLength,
         hingeColor: hingeColor,
         digitSpacing: digitSpacing,
       );

  Widget buildDaysDisplay(Stream<int> timePartStream, int initValue) {
    final initValueAsString = "${initValue.abs()}".padLeft(2, '0');
    final List<Widget> displays = [];

    for (var i = 0; i < initValueAsString.length; i++) {
      final digitStream = timePartStream.map<int>((value) {
        return (value ~/ (pow(10, initValueAsString.length - 1 - i))) % 10;
      });

      displays.add(_buildDisplay(digitStream, int.parse(initValueAsString[i])));
    }

    return Row(children: displays);
  }

  Widget _buildDisplay(Stream<int> digitStream, int initialValue) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: digitSpacing,
        child: FlipWidget<int>(
          flipType: FlipType.middleFlip,
          itemStream: digitStream,
          itemBuilder: _digitBuilder,
          initialValue: initialValue,
          hingeWidth: hingeWidth,
          hingeLength: hingeLength,
          hingeColor: hingeColor,
          flipDirection: flipDirection,
          flipCurve: flipCurve ?? FlipWidget.defaultFlip,
        ),
      ),
    ],
  );

  Widget _digitBuilder(BuildContext context, int? digit) => Container(
    decoration: BoxDecoration(
      color: backgroundColor ?? Theme.of(context).colorScheme.primary,
      borderRadius: borderRadius,
      border: showBorder
          ? Border.all(
              color: borderColor ?? Theme.of(context).colorScheme.onPrimary,
              width: borderWidth ?? 1.0,
            )
          : null,
    ),
    width: width,
    height: height,
    alignment: Alignment.center,
    child: Text(
      digit == null ? ' ' : digit.toString(),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: digitSize,
        color: digitColor ?? Theme.of(context).colorScheme.onPrimary,
      ),
    ),
  );
}
