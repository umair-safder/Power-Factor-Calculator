import 'dart:math' as math;

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
}

class PowerFactorCalculator {
  const PowerFactorCalculator._();

  static PowerFactorResult calculate(PowerFactorInput input) {
    return calculateFromPVandCos(
      input.realPower,
      input.voltage,
      input.powerFactor,
    );
  }

  /// Calculate Current, Reactive Power, and Apparent Power from Power, Voltage, and cos(θ)
  ///
  /// Inputs:
  /// - [realPower] P in Watts (W)
  /// - [voltage] V in Volts (V)
  /// - [powerFactor] cos(θ), must be between 0 and 1
  ///
  /// Returns:
  /// - Apparent Power S = P / PF (VA)
  /// - Current I = S / V = P / (V × PF) (A)
  /// - Reactive Power Q = √(S² - P²) = S × sin(θ) (VAR)
  static PowerFactorResult calculateFromPVandCos(
    double realPower,
    double voltage,
    double powerFactor,
  ) {
    if (realPower < 0) {
      return PowerFactorResult(note: 'Power (P) must be positive.');
    }
    if (voltage <= 0) {
      return PowerFactorResult(
        note: 'Voltage (V) must be positive and non-zero.',
      );
    }
    if (powerFactor <= 0 || powerFactor > 1) {
      return PowerFactorResult(
        note: 'Power Factor (cos θ) must be between 0 and 1.',
      );
    }

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

  static String formatNumber(double value) {
    if (value.abs() >= 1000) {
      return value.toStringAsFixed(2);
    }
    return value.toStringAsFixed(3);
  }

  static double powerFactorToPercent(double powerFactor) {
    return (powerFactor * 100).clamp(0.0, 100.0);
  }
}
