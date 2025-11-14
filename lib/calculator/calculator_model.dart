// lib/calculator/calculator_model.dart

import 'dart:math' as math;

/// --- 1. Input Model ---
/// Data class to hold the raw user input values.
class PowerFactorInput {
  const PowerFactorInput({
    required this.realPower,
    required this.voltage,
    required this.powerFactor,
  });

  final double realPower;
  final double voltage;
  final double powerFactor;
}

/// --- 2. Result Model ---
/// Data class to hold the calculated results and notes.
/// Includes methods for Firestore serialization/deserialization.
class PowerFactorResult {
  const PowerFactorResult({
    this.powerFactor,
    this.realPower,
    this.apparentPower,
    this.current,
    this.reactivePower,
    this.note,
  });

  final double? powerFactor;
  final double? realPower;
  final double? apparentPower;
  final double? current;
  final double? reactivePower;
  final String? note;

  bool get hasMetrics =>
      current != null || apparentPower != null || reactivePower != null;

  /// Factory constructor to create a result object from a Firestore Map.
  factory PowerFactorResult.fromMap(Map<String, dynamic> map) {
    return PowerFactorResult(
      powerFactor: (map['powerFactor'] as num?)?.toDouble(),
      realPower: (map['realPower'] as num?)?.toDouble(),
      apparentPower: (map['apparentPower'] as num?)?.toDouble(),
      current: (map['current'] as num?)?.toDouble(),
      reactivePower: (map['reactivePower'] as num?)?.toDouble(),
      note: map['note'] as String?,
    );
  }

  /// Method for converting the object to a Firestore Map.
  Map<String, dynamic> toMap() {
    return {
      'powerFactor': powerFactor,
      'realPower': realPower,
      'apparentPower': apparentPower,
      'current': current,
      'reactivePower': reactivePower,
      'note': note,
    };
  }
}

/// --- 3. Deprecated Static Calculator (Retained temporarily for UI compatibility) ---
/// NOTE: The core logic has been moved to DefaultCalculatorService.
/// This class will eventually be removed once all UI widgets are updated.
class PowerFactorCalculator {
  const PowerFactorCalculator._();

  // Helper method to satisfy existing Controller code (calls the old static logic)
  static PowerFactorResult calculate(PowerFactorInput input) {
    return calculateFromPVandCos(
      input.realPower,
      input.voltage,
      input.powerFactor,
    );
  }

  /// Calculate Current, Reactive Power, and Apparent Power from Power, Voltage, and cos(θ)
  static PowerFactorResult calculateFromPVandCos(
      double realPower,
      double voltage,
      double powerFactor,
      ) {
    // Input validation checks (simplified, detailed checks are in the service)
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

    // Calculation logic
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

  static double powerFactorToPercent(double pf) => pf * 100;

  static String classifyPowerFactor(double powerFactor) {
    if (powerFactor >= 0.95) return 'Excellent';
    if (powerFactor >= 0.9) return 'Good';
    if (powerFactor >= 0.8) return 'Fair';
    return 'Poor';
  }

  static String getPowerFactorInterpretation(double powerFactor) {
    if (powerFactor >= 0.95) {
      return 'almost unity';
    } else if (powerFactor >= 0.8) {
      return 'non-ideal — consider correction';
    } else {
      return 'poor — correction recommended';
    }
  }
}