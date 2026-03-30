import 'package:flutter/material.dart';
import 'package:jobgo/data/models/employer_model.dart';
import 'package:jobgo/data/repositories/employer_repository.dart';

class EmployerProvider extends ChangeNotifier {
  final EmployerRepository _repository = EmployerRepository();
  EmployerModel? _employer;
  bool _isLoading = false;

  EmployerModel? get employer => _employer;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    _employer = await _repository.getCurrentEmployer();

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile(EmployerModel updatedEmployer) async {
    if (_employer?.id == null) return false;

    _isLoading = true;
    notifyListeners();

    final success = await _repository.updateEmployerProfile(
      _employer!.id!,
      updatedEmployer,
    );
    if (success) {
      _employer = updatedEmployer.copyWith(); // Keep current IDs
      // Note: copyWith in EmployerModel preserves IDs by default if not passed
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  void clearProfile() {
    _employer = null;
    notifyListeners();
  }
}
