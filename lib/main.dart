import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:syncfusion_flutter_core/theme.dart';

String verticalText = '';
String horizontalText = '';

void main() {
  return runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
      debugShowCheckedModeBanner: false,
      home: CustomCrosshair(),
    );
  }
}

class CustomCrosshair extends StatefulWidget {
  const CustomCrosshair({super.key});

  @override
  State<CustomCrosshair> createState() => _CustomCrosshairState();
}

class _CustomCrosshairState extends State<CustomCrosshair> {
  late List<ChartData> chartData;

  @override
  void initState() {
    chartData = [
      ChartData(DateTime(2024, 2, 1), 1),
      ChartData(DateTime(2024, 2, 2), 19),
      ChartData(DateTime(2024, 2, 3), 11),
      ChartData(DateTime(2024, 2, 4), 41),
      ChartData(DateTime(2024, 2, 5), 11),
      ChartData(DateTime(2024, 2, 6), 51),
      ChartData(DateTime(2024, 2, 7), 71),
      ChartData(DateTime(2024, 2, 8), 31),
      ChartData(DateTime(2024, 2, 9), 15),
      ChartData(DateTime(2024, 2, 10), 21),
      ChartData(DateTime(2024, 2, 11), 32),
      ChartData(DateTime(2024, 2, 12), 23),
      ChartData(DateTime(2024, 2, 13), 21),
      ChartData(DateTime(2024, 2, 14), 12),
      ChartData(DateTime(2024, 2, 15), 40),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCartesianChart(
        onCrosshairPositionChanging: (CrosshairRenderArgs args) {
          if (args.orientation != null) {
            if (args.orientation == AxisOrientation.horizontal) {
              horizontalText = args.text;
            }
            if (args.orientation == AxisOrientation.vertical) {
              verticalText = args.text;
            }
          }
        },
        crosshairBehavior: _CustomCrosshairBehavior(),
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat.MEd(),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
        ),
        series: <CartesianSeries<ChartData, DateTime>>[
          SplineSeries(
            dataSource: chartData,
            xValueMapper: (ChartData sales, _) => sales.x,
            yValueMapper: (ChartData sales, _) => sales.y,
            markerSettings: MarkerSettings(isVisible: true),
            animationDuration: 0,
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);

  final DateTime x;
  final double y;
}

class _CustomCrosshairBehavior extends CrosshairBehavior {
  @override
  bool get enable => true;

  @override
  ActivationMode get activationMode => ActivationMode.singleTap;

  Offset? position;

  @override
  void show(x, double y, [String coordinateUnit = 'point']) {
    if (coordinateUnit == 'pixel') {
      position = Offset(x.toDouble(), y);
    }
    super.show(x, y, 'pixel');
  }

  @override
  void drawHorizontalAxisLine(PaintingContext context, Offset offset,
      List<double>? dashArray, Paint strokePaint) {
    strokePaint
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..color = Colors.red
      ..strokeWidth = 1.2;
    dashArray = [10, 15, 10];
    super.drawHorizontalAxisLine(context, offset, dashArray, strokePaint);
  }

  @override
  void drawVerticalAxisLine(PaintingContext context, Offset offset,
      List<double>? dashArray, Paint strokePaint) {
    strokePaint
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..color = Colors.green
      ..strokeWidth = 1.2;
    dashArray = [5, 10, 5];
    super.drawVerticalAxisLine(context, offset, dashArray, strokePaint);
  }

  @override
  void drawVerticalAxisTooltip(
      PaintingContext context, Offset position, String text, TextStyle style,
      [Path? path, Paint? fillPaint, Paint? strokePaint]) {
    // Don't invoke default tooltip.
  }

  @override
  void drawHorizontalAxisTooltip(
      PaintingContext context, Offset position, String text, TextStyle style,
      [Path? path, Paint? fillPaint, Paint? strokePaint]) {
    // Don't invoke default tooltip.
  }

  @override
  void onPaint(PaintingContext context, Offset offset,
      SfChartThemeData chartThemeData, ThemeData themeData) {
    if (position != null && horizontalText != '' && verticalText != '') {
      // Draws crosshair lines.
      super.onPaint(context, offset, chartThemeData, themeData);
      // Draw customized tooltip.
      TextStyle textStyle = TextStyle(
          color: Colors.white,
          fontSize: 12,
          background: Paint()
            ..color = Colors.blueGrey
            ..strokeWidth = 16
            ..strokeJoin = StrokeJoin.round
            ..style = dart_ui.PaintingStyle.stroke);

      final String label = 'X : $horizontalText  Y : $verticalText';
      final Size labelSize = measureText(label, textStyle);
      _drawText(context.canvas, label, _withInBounds(labelSize), textStyle);
    }
  }

  Offset _withInBounds(Size labelSize) {
    Offset tooltipPosition = position!.translate(20, 20);
    double xPos = tooltipPosition.dx;
    double yPos = tooltipPosition.dy;
    if (parentBox != null) {
      final Rect plotAreaBounds = parentBox!.paintBounds;
      if (xPos + labelSize.width > plotAreaBounds.right) {
        xPos = plotAreaBounds.right - labelSize.width - labelSize.height;
      }
      if (yPos + labelSize.height > plotAreaBounds.bottom) {
        yPos = plotAreaBounds.bottom - (labelSize.height * 2);
      }
    }
    return Offset(xPos, yPos);
  }

  void _drawText(Canvas canvas, String text, Offset point, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
          text: text,
          style: style.copyWith(fontWeight: dart_ui.FontWeight.bold)),
      textAlign: TextAlign.center,
      textDirection: dart_ui.TextDirection.ltr,
    );
    textPainter
      ..layout()
      ..paint(canvas, point);
  }

  @override
  void hide() {
    position = null;
    horizontalText = '';
    verticalText = '';
    super.hide();
  }
}
