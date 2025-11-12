import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'calculator_model.dart';

class PowerFactorController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController realPowerController = TextEditingController();
  final TextEditingController voltageController = TextEditingController();
  final TextEditingController powerFactorController = TextEditingController();

  final Rxn<PowerFactorResult> _result = Rxn<PowerFactorResult>();
  final RxString _note = ''.obs;

  PowerFactorResult? get result => _result.value;
  String? get note {
    final note = _note.value.isEmpty ? null : _note.value;
    return note ?? _result.value?.note;
  }

  bool get hasPowerFactor => _result.value?.powerFactor != null;
  bool get hasMetrics => _result.value?.hasMetrics ?? false;

  void calculate() {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    _result.value = null;
    _note.value = '';

    final input = _parseInput();
    if (input == null) {
      _note.value = 'Enter valid Power (W), Voltage (V), and cos(θ).';
      return;
    }

    final calculated = PowerFactorCalculator.calculate(input);
    _result.value = calculated;
    _note.value = calculated.note ?? '';
  }

  PowerFactorInput? _parseInput() {
    final realPower = double.tryParse(realPowerController.text);
    final voltage = double.tryParse(voltageController.text);
    final powerFactor = double.tryParse(powerFactorController.text);

    if (realPower == null || voltage == null || powerFactor == null) {
      return null;
    }

    return PowerFactorInput(
      realPower: realPower,
      voltage: voltage,
      powerFactor: powerFactor,
    );
  }

  @override
  void onClose() {
    realPowerController.dispose();
    voltageController.dispose();
    powerFactorController.dispose();
    super.onClose();
  }
}
