import 'package:flutter/material.dart';

class CalculatorNumberField extends StatelessWidget {
  const CalculatorNumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.allowNegative = false,
    this.mustBeNonZero = false,
    this.isPowerFactor = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool allowNegative;
  final bool mustBeNonZero;
  final bool isPowerFactor;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
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
      validator: _validator,
      onFieldSubmitted: (_) => onSubmitted?.call(),
    );
  }

  String? _validator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    final parsed = double.tryParse(value);
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (!allowNegative && parsed < 0) {
      return 'Value must be positive';
    }
    if (mustBeNonZero && parsed == 0) {
      return 'Value must not be zero';
    }
    if (isPowerFactor && (parsed <= 0 || parsed > 1)) {
      return 'Power Factor must be between 0 and 1';
    }
    return null;
  }
}

