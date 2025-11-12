import 'package:flutter/material.dart';
import '../calculator_controller.dart';
import '../calculator_model.dart';

class CalculatorResultCard extends StatelessWidget {
  const CalculatorResultCard({
    super.key,
    required this.controller,
  });

  final PowerFactorController controller;

  @override
  Widget build(BuildContext context) {
    final result = controller.result;
    final note = controller.note;
    final hasMetrics = controller.hasMetrics && result != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Result',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildResultDetails(
                    hasPowerFactor: controller.hasPowerFactor,
                    powerFactorValue: result?.powerFactor,
                    result: result,
                    hasMetrics: hasMetrics,
                    note: note,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResultDetails({
    required bool hasPowerFactor,
    required double? powerFactorValue,
    required PowerFactorResult? result,
    required bool hasMetrics,
    required String? note,
  }) {
    final widgets = <Widget>[
      Center(
        child: !hasPowerFactor || powerFactorValue == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    note ?? 'No calculation yet',
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : _ResultSummary(powerFactorValue),
      ),
    ];

    if (hasMetrics && result != null) {
      widgets.addAll([
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        if (result.current != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Current I: ${PowerFactorCalculator.formatNumber(result.current!)} A',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        if (result.apparentPower != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Apparent Power S: ${PowerFactorCalculator.formatNumber(result.apparentPower!)} VA',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        if (result.reactivePower != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Reactive Power Q: ${PowerFactorCalculator.formatNumber(result.reactivePower!)} VAR',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
      ]);
    }

    if (note != null) {
      widgets.addAll([
        const SizedBox(height: 8),
        Text(note, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ]);
    }

    return widgets;
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary(this.pf);

  final double pf;

  @override
  Widget build(BuildContext context) {
    final percent = PowerFactorCalculator.powerFactorToPercent(pf);
    final classification = PowerFactorCalculator.classifyPowerFactor(pf);
    final interpretation =
        PowerFactorCalculator.getPowerFactorInterpretation(pf);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(value: pf, strokeWidth: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pf.toStringAsFixed(3),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${percent.toStringAsFixed(1)} %',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Classification: $classification',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          'Power Factor interpretation: $interpretation',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

