
import '../calculator/calculator_model.dart';

/// Defines the contract for any service that handles saving and retrieving
/// power factor calculation history.
abstract class IHistoryRepository {
  /// Returns a stream of the history list, updating automatically.
  Stream<List<PowerFactorResult>> getHistoryStream();

  /// Saves a new calculation result to the data source.
  Future<void> saveResult(PowerFactorResult result);

  /// Clears all stored history.
  Future<void> clearHistory();
}