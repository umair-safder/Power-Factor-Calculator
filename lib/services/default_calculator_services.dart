// lib/calculator/default_calculator_service.dart

import 'dart:math' as math;
import 'package:intl/intl.dart';

import '../calculator/calculator_model.dart';
import 'i_calculator_services.dart'; // FIX: Added missing import for NumberFormat

/// The concrete implementation of the power factor calculation logic.
class DefaultCalculatorService implements ICalculatorService {
  const DefaultCalculatorService();

  // Helper for consistent number formatting (moved from old PowerFactorCalculator)
  // FIX: NumberFormat is now accessible
  static final NumberFormat _formatter = NumberFormat('0.0##');

  // Implementation of abstract method: Main calculation
  @override
  PowerFactorResult calculateFromPVandCos({
    required double realPower,
    required double voltage,
    required double powerFactor,
  }) {
    // Input validation checks (moved from old PowerFactorCalculator)
    if (realPower <= 0) {
      return const PowerFactorResult(
        note: 'Real Power (P) must be positive and non-zero.',
      );
    }
    if (voltage <= 0) {
      return const PowerFactorResult(
        note: 'Voltage (V) must be positive and non-zero.',
      );
    }
    if (powerFactor <= 0 || powerFactor > 1) {
      return const PowerFactorResult(
        note: 'Power Factor (cos θ) must be between 0 and 1.',
      );
    }

    // Calculation logic (moved from old PowerFactorCalculator)
    final apparentPower = realPower / powerFactor;
    final current = apparentPower / voltage;
    final sinTheta = math.sqrt(1 - (powerFactor * powerFactor));
    final reactivePower = apparentPower * sinTheta;

    return PowerFactorResult(
      powerFactor: powerFactor,
      realPower: realPower,
      apparentPower: apparentPower,
      current: current,
      reactivePower: reactivePower,
      note: 'Calculated from P, V, and cos(θ)',
    );
  }

  // Implementation of abstract method: Classification
  @override
  String classifyPowerFactor(double powerFactor) {
    if (powerFactor >= 0.95) return 'Excellent';
    if (powerFactor >= 0.9) return 'Good';
    if (powerFactor >= 0.8) return 'Fair';
    return 'Poor';
  }

  // Implementation of abstract method: Interpretation
  @override
  String getPowerFactorInterpretation(double powerFactor) {
    if (powerFactor >= 0.95) {
      return 'almost unity';
    } else if (powerFactor >= 0.8) {
      return 'non-ideal — consider correction';
    } else {
      return 'poor — correction recommended';
    }
  }

  // Implementation of abstract method: Percentage conversion
  @override
  double powerFactorToPercent(double powerFactor) {
    return powerFactor * 100;
  }

  // Implementation of abstract method: Number formatting
  @override
  String formatNumber(double number) {
    // Uses the correctly imported and defined static formatter
    return _formatter.format(number);
  }
}