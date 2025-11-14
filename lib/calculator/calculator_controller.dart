// lib/calculator/calculator_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../repository/i_history_repository.dart';
import '../services/i_calculator_services.dart';
import 'calculator_model.dart';

class PowerFactorController extends GetxController {

  // INJECT DEPENDENCIES: Use Get.find() to get the concrete implementations
  final ICalculatorService _calculatorService = Get.find<ICalculatorService>();
  final IHistoryRepository _historyRepository = Get.find<IHistoryRepository>();

  // NEW GETTER: Expose the abstract service for UI widgets (like CalculatorResultCard)
  // to access classification and formatting methods without relying on statics.
  ICalculatorService get service => _calculatorService;

  final RxList<PowerFactorResult> history = <PowerFactorResult>[].obs;

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

  @override
  void onInit() {
    super.onInit();
    // Start listening to history using the abstract repository
    fetchHistory();
  }

  // UPDATED METHOD: Listens to the Repository stream
  void fetchHistory() {
    _historyRepository.getHistoryStream().listen((fetchedHistory) {
      history.assignAll(fetchedHistory);
    });
  }

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

    // USE ABSTRACT SERVICE: Call the method on the injected service
    final calculated = _calculatorService.calculateFromPVandCos(
      realPower: input.realPower,
      voltage: input.voltage,
      powerFactor: input.powerFactor,
    );

    _result.value = calculated;
    _note.value = calculated.note ?? '';

    // Call the function to save the history
    _saveHistory(calculated);
  }

  // UPDATED METHOD: Use Repository to save history
  Future<void> _saveHistory(PowerFactorResult result) async {
    if (result.powerFactor == null) {
      return;
    }

    try {
      await _historyRepository.saveResult(result);
      print('History saved successfully!');
    } catch (e) {
      print('Error saving history: $e');
    }
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