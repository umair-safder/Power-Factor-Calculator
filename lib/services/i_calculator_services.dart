// lib/calculator/i_calculator_service.dart



import '../calculator/calculator_model.dart';

/// Defines the contract for any service that handles power factor calculations
/// and interpretations. This allows for easy swapping of calculation logic.
abstract class ICalculatorService {
  // Main calculation method
  PowerFactorResult calculateFromPVandCos({
    required double realPower,
    required double voltage,
    required double powerFactor,
  });

  // Classification and Interpretation methods (used by the UI)
  String classifyPowerFactor(double powerFactor);
  String getPowerFactorInterpretation(double powerFactor);

  // Utility methods (used by the UI)
  double powerFactorToPercent(double powerFactor);
  String formatNumber(double number);
}