// lib/calculator/history/firestore_history_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../calculator/calculator_model.dart';
import 'i_history_repository.dart';

class FirestoreHistoryRepository implements IHistoryRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'calculator_history';

  const FirestoreHistoryRepository(this._firestore);

  @override
  Stream<List<PowerFactorResult>> getHistoryStream() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        // We assume 'fromMap' and 'timestamp' handling is added to PowerFactorResult
        return PowerFactorResult.fromMap(doc.data());
      }).toList();
    });
  }

  @override
  Future<void> saveResult(PowerFactorResult result) async {
    // Only save successful calculations
    if (result.powerFactor == null) {
      return;
    }

    // Add server timestamp for sorting
    final Map<String, dynamic> data = {
      ...result.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection(_collection).add(data);
    } catch (e) {
      // Handle or re-throw error
      print('Error saving history: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearHistory() {
    // Implement batch deletion logic here if needed
    throw UnimplementedError('clearHistory not yet implemented for Firestore');
  }
}