import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'calculator_controller.dart';
import 'widgets/calculator_input_card.dart';
import 'widgets/calculator_result_card.dart';

class CalculatorScreen extends GetView<PowerFactorController> {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 840;
        final spacing = isWide ? 24.0 : 16.0;

        return Padding(
          padding: EdgeInsets.all(isWide ? 24.0 : 16.0),
          child: Form(
            key: controller.formKey,
            child: isWide
                ? _buildWideLayout(spacing)
                : _buildNarrowLayout(spacing),
          ),
        );
      },
    );
  }

  Widget _buildNarrowLayout(double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Power Factor Calculator',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: spacing),
        CalculatorInputCard(controller: controller),
        SizedBox(height: spacing),
        Expanded(child: CalculatorResultCard(controller: controller)),
      ],
    );
  }

  Widget _buildWideLayout(double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Power Factor Calculator',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: spacing),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: spacing),
                  child: CalculatorInputCard(controller: controller),
                ),
              ),
              SizedBox(width: spacing),
              Expanded(
                flex: 6,
                child: Obx(() => CalculatorResultCard(controller: controller)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
