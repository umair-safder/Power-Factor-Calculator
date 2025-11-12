// main.dart
// Power Factor Calculator - Flutter
// UI for calculating power factor

import 'package:flutter/material.dart';
import 'power_factor_math.dart' as pfMath;

void main() => runApp(const PowerFactorApp());

class PowerFactorApp extends StatelessWidget {
  const PowerFactorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Power Factor Calculator',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const Scaffold(body: SafeArea(child: PowerFactorCalculator())),
    );
  }
}

class PowerFactorCalculator extends StatefulWidget {
  const PowerFactorCalculator({super.key});

  @override
  State<PowerFactorCalculator> createState() => _PowerFactorCalculatorState();
}

class _PowerFactorCalculatorState extends State<PowerFactorCalculator> {
  // controllers for inputs
  final TextEditingController _pController =
      TextEditingController(); // Real power (W)
  final TextEditingController _vController =
      TextEditingController(); // Voltage (V)
  final TextEditingController _cosController =
      TextEditingController(); // cos(θ) - Power Factor

  double? _pf; // power factor (0..1)
  double? _sResult; // computed apparent power
  double? _iResult; // computed current
  double? _qResult; // computed reactive power
  String? _note;

  final _formKey = GlobalKey<FormState>();

  void _calculate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _pf = null;
      _sResult = null;
      _iResult = null;
      _qResult = null;
      _note = null;

      final p = double.tryParse(_pController.text);
      final v = double.tryParse(_vController.text);
      final cosTheta = double.tryParse(_cosController.text);

      if (p == null || v == null || cosTheta == null) {
        _note = 'Enter valid Power (W), Voltage (V), and cos(θ).';
        return;
      }

      final result = pfMath.PowerFactorCalculator.calculateFromPVandCos(
        p,
        v,
        cosTheta,
      );
      if (result != null) {
        _pf = result.powerFactor;
        _sResult = result.apparentPower;
        _iResult = result.current;
        _qResult = result.reactivePower;
        _note = result.note;
      } else {
        _note = 'Invalid calculation.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Power Factor Calculator',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // input card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    _numberField(
                      _pController,
                      'Power P (W)',
                      'e.g. 1200',
                      isRequired: true,
                      allowNegative: false,
                    ),
                    const SizedBox(height: 8),
                    _numberField(
                      _vController,
                      'Voltage V (V)',
                      'e.g. 230',
                      isRequired: true,
                      allowNegative: false,
                      mustBeNonZero: true,
                    ),
                    const SizedBox(height: 8),
                    _numberField(
                      _cosController,
                      'Power Factor cos(θ)',
                      'e.g. 0.8 (0 to 1)',
                      isRequired: true,
                      allowNegative: false,
                      mustBeNonZero: true,
                      isPowerFactor: true,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // result card
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Result',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: _pf == null
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.info_outline, size: 48),
                                    const SizedBox(height: 8),
                                    Text(
                                      _note ?? 'No calculation yet',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              : _resultWidget(_pf ?? 0),
                        ),
                      ),

                      if (_iResult != null ||
                          _sResult != null ||
                          _qResult != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(height: 8),
                            if (_iResult != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'Current I: ${pfMath.PowerFactorCalculator.formatNumber(_iResult!)} A',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (_sResult != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'Apparent Power S: ${pfMath.PowerFactorCalculator.formatNumber(_sResult!)} VA',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            if (_qResult != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'Reactive Power Q: ${pfMath.PowerFactorCalculator.formatNumber(_qResult!)} VAR',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                          ],
                        ),

                      if (_note != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _note!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isRequired = true,
    bool allowNegative = false,
    bool mustBeNonZero = false,
    bool isPowerFactor = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'This field is required';
        }
        if (value != null && value.trim().isNotEmpty) {
          final num = double.tryParse(value);
          if (num == null) {
            return 'Enter a valid number';
          }
          if (!allowNegative && num < 0) {
            return 'Value must be positive';
          }
          if (mustBeNonZero && num == 0) {
            return 'Value must not be zero';
          }
          if (isPowerFactor && (num <= 0 || num > 1)) {
            return 'Power Factor must be between 0 and 1';
          }
        }
        return null;
      },
      onFieldSubmitted: (_) => _calculate(),
    );
  }

  Widget _resultWidget(double pf) {
    final percent = pfMath.PowerFactorCalculator.powerFactorToPercent(pf);
    final classification = pfMath.PowerFactorCalculator.classifyPowerFactor(pf);
    final interpretation =
        pfMath.PowerFactorCalculator.getPowerFactorInterpretation(pf);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular visualisation using CircularProgressIndicator
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: pf, // 0..1
                strokeWidth: 12,
                // don't set explicit colors here so user can theme it
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pf.toStringAsFixed(3),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${percent.toStringAsFixed(1)} %',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Classification: $classification',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          'Power Factor interpretation: $interpretation',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pController.dispose();
    _vController.dispose();
    _cosController.dispose();
    super.dispose();
  }
}
