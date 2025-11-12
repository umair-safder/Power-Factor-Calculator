// main.dart
// Power Factor Calculator - Flutter
// UI for calculating power factor

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'calculator/calculator_controller.dart';
import 'calculator/calculator_screen.dart';

void main() {
  runApp(const PowerFactorApp());
}

class PowerFactorApp extends StatelessWidget {
  const PowerFactorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Power Factor Calculator',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      initialBinding: BindingsBuilder(
        () => Get.lazyPut(() => PowerFactorController(), fenix: true),
      ),
      home: const Scaffold(body: SafeArea(child: CalculatorScreen())),
    );
  }
}
