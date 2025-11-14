// lib/main.dart
// Power Factor Calculator - Flutter
// UI for calculating power factor

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // REQUIRED: For injecting Firestore instance
import 'package:powerfactor/repository/firestore_history_repository.dart';
import 'package:powerfactor/repository/i_history_repository.dart';
import 'package:powerfactor/services/default_calculator_services.dart';
import 'package:powerfactor/services/i_calculator_services.dart';

import 'firebase_options.dart';
import 'calculator/calculator_controller.dart';
import 'calculator/calculator_screen.dart';
Future<void> main() async {
  // 1. Ensure Flutter bindings are initialized (required before using Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. AWAIT Firebase initialization before starting the app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. THEN, run the app
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
            () {
          // --- Dependency Injection Setup ---
          // 1. Register FirebaseFirestore instance (Singleton)
          Get.lazyPut(() => FirebaseFirestore.instance, fenix: true);

          // 2. Register the Abstract Calculator Service with its concrete implementation
          Get.lazyPut<ICalculatorService>(() => const DefaultCalculatorService(), fenix: true);

          // 3. Register the Abstract History Repository with its concrete implementation
          // We pass the Firestore instance, retrieved via Get.find()
          Get.lazyPut<IHistoryRepository>(
                () => FirestoreHistoryRepository(Get.find<FirebaseFirestore>()),
            fenix: true,
          );

          // 4. Register the Controller (which now relies on the injected interfaces)
          Get.lazyPut(() => PowerFactorController(), fenix: true);
        },
      ),
      home: const Scaffold(body: SafeArea(child: CalculatorScreen())),
    );
  }
}