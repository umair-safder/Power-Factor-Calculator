// power_factor_math.dart
// Power Factor calculation utilities and formulas

import 'dart:math' as math;

/// Result of a power factor calculation
class PowerFactorResult {
  final double? powerFactor; // 0..1
  final double? realPower; // P (W)
  final double? apparentPower; // S (VA)
  final double? current; // I (A)
  final double? reactivePower; // Q (VAR)
  final String note; // Description of the calculation

  const PowerFactorResult({
    this.powerFactor,
    this.realPower,
    this.apparentPower,
    this.current,
    this.reactivePower,
    required this.note,
  });
}

/// Power Factor calculation utilities
class PowerFactorCalculator {
  /// Calculate power factor from real power (P) and apparent power (S)
  /// Formula: PF = P / S
  ///
  /// Returns null if inputs are invalid
  static PowerFactorResult? calculateFromPandS(double p, double s) {
    if (s == 0) {
      return PowerFactorResult(note: 'S (apparent power) must not be zero.');
    }
    if (p < 0 || s < 0) {
      return PowerFactorResult(note: 'P and S must be positive values.');
    }

    final pf = (p / s).clamp(0.0, 1.0);
    return PowerFactorResult(
      powerFactor: pf,
      realPower: p,
      apparentPower: s,
      note: 'PF = P / S',
    );
  }

  /// Calculate apparent power from voltage (V) and current (I)
  /// Formula: S = V × I
  static double calculateApparentPower(double voltage, double current) {
    return voltage * current;
  }

  /// Calculate power factor from phase angle (in degrees)
  /// Formula: PF = |cos(θ)|
  ///
  /// [angleDegrees] is the phase angle in degrees
  static double calculatePowerFactorFromAngle(double angleDegrees) {
    final theta = angleDegrees * math.pi / 180.0;
    return math.cos(theta).abs().clamp(0.0, 1.0);
  }

  /// Calculate real power from apparent power and power factor
  /// Formula: P = S × PF
  static double calculateRealPower(double apparentPower, double powerFactor) {
    return apparentPower * powerFactor;
  }

  /// Calculate power factor from voltage, current, and optional angle
  ///
  /// If [angleDegrees] is null, only apparent power is calculated
  static PowerFactorResult calculateFromVandI(
    double voltage,
    double current, {
    double? angleDegrees,
  }) {
    if (voltage < 0 || current < 0) {
      return PowerFactorResult(note: 'V and I must be positive values.');
    }

    final s = calculateApparentPower(voltage, current);

    if (angleDegrees == null) {
      return PowerFactorResult(
        apparentPower: s,
        note: 'Angle empty — computed S only. Provide angle to get PF.',
      );
    }

    final pf = calculatePowerFactorFromAngle(angleDegrees);
    final p = calculateRealPower(s, pf);

    return PowerFactorResult(
      powerFactor: pf,
      realPower: p,
      apparentPower: s,
      note: 'PF = cos(θ) using provided angle',
    );
  }

  /// Classify power factor quality
  ///
  /// Returns: 'Excellent' (≥0.95), 'Good' (≥0.9), 'Fair' (≥0.8), or 'Poor' (<0.8)
  static String classifyPowerFactor(double powerFactor) {
    if (powerFactor >= 0.95) return 'Excellent';
    if (powerFactor >= 0.9) return 'Good';
    if (powerFactor >= 0.8) return 'Fair';
    return 'Poor';
  }

  /// Get interpretation text for power factor
  static String getPowerFactorInterpretation(double powerFactor) {
    if (powerFactor >= 0.95) {
      return 'almost unity';
    } else if (powerFactor >= 0.8) {
      return 'non-ideal — consider correction';
    } else {
      return 'poor — correction recommended';
    }
  }

  /// Format a number for display
  ///
  /// Uses 2 decimal places for values ≥ 1000, 3 decimal places otherwise
  static String formatNumber(double value) {
    if (value.abs() >= 1000) {
      return value.toStringAsFixed(2);
    }
    return value.toStringAsFixed(3);
  }

  /// Convert power factor to percentage
  static double powerFactorToPercent(double powerFactor) {
    return (powerFactor * 100).clamp(0.0, 100.0);
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
  static PowerFactorResult? calculateFromPVandCos(
    double realPower,
    double voltage,
    double powerFactor,
  ) {
    // Validate inputs
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

    // Calculate Apparent Power: S = P / PF
    final apparentPower = realPower / powerFactor;

    // Calculate Current: I = S / V = P / (V × PF)
    final current = apparentPower / voltage;

    // Calculate Reactive Power: Q = √(S² - P²) = S × sin(θ)
    // sin(θ) = √(1 - cos²(θ))
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
}
