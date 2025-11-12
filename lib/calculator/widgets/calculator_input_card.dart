import 'package:flutter/material.dart';

import '../calculator_controller.dart';
import 'calculator_number_field.dart';

class CalculatorInputCard extends StatelessWidget {
  const CalculatorInputCard({
    super.key,
    required this.controller,
  });

  final PowerFactorController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CalculatorNumberField(
              controller: controller.realPowerController,
              label: 'Power P (W)',
              hint: 'e.g. 1200',
              onSubmitted: controller.calculate,
            ),
            const SizedBox(height: 8),
            CalculatorNumberField(
              controller: controller.voltageController,
              label: 'Voltage V (V)',
              hint: 'e.g. 230',
              mustBeNonZero: true,
              onSubmitted: controller.calculate,
            ),
            const SizedBox(height: 8),
            CalculatorNumberField(
              controller: controller.powerFactorController,
              label: 'Power Factor cos(θ)',
              hint: 'e.g. 0.8 (0 to 1)',
              mustBeNonZero: true,
              isPowerFactor: true,
              onSubmitted: controller.calculate,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: controller.calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate'),
            ),
          ],
        ),
      ),
    );
  }
}

