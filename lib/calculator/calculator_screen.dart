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
    // FIXED: Using ListView is the most robust solution for a scrollable screen
    return ListView(
      padding: EdgeInsets.zero, // Padding is already applied by the parent Padding widget
      children: [
        const SizedBox(height: 8),
        const Text(
          'Power Factor Calculator',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: spacing),
        CalculatorInputCard(controller: controller),
        SizedBox(height: spacing),
        CalculatorResultCard(controller: controller),

        // ADDED: History Section
        SizedBox(height: spacing * 1.5),
        const Text(
          'Recent History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: spacing / 2),
        const HistoryList(),
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
                // The left column (Input) now contains the history
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CalculatorInputCard(controller: controller),

                      // ADDED: History Section
                      SizedBox(height: spacing * 1.5),
                      const Text(
                        'Recent History',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: spacing / 2),
                      const HistoryList(),
                    ],
                  ),
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

// -------------------------------------------------------------------------
// NEW WIDGET: HistoryList (Fixed for Null Check Error)
// -------------------------------------------------------------------------

class HistoryList extends GetView<PowerFactorController> {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    // Obx listens to the controller.history list and rebuilds when data arrives
    return Obx(() {
      if (controller.history.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('No calculation history yet.'),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        // Disable scrolling in the list since the parent (ListView/SingleChildScrollView) handles it
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.history.length,
        itemBuilder: (context, index) {
          final result = controller.history[index];

          // CRITICAL FIX: Create safe local strings before interpolation
          final pf = result.powerFactor?.toStringAsFixed(3) ?? 'N/A';
          final realP = result.realPower?.toStringAsFixed(2) ?? 'N/A';
          final currentI = result.current?.toStringAsFixed(2) ?? 'N/A';

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                'PF: $pf', // Use the safe local variable
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                // Use the safe local variables
                'P: $realP W | I: $currentI A',
              ),
            ),
          );
        },
      );
    });
  }
}