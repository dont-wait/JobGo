import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/employer_model.dart';
import '../../data/repositories/employer_repository.dart';

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
      _employer = updatedEmployer;
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Picks a new logo, uploads it to Supabase, and updates the profile URL.
  Future<bool> uploadAndChangeLogo(File file) async {
    if (_employer?.id == null) return false;

    _isLoading = true;
    notifyListeners();

    final fileName =
        'logo_${_employer!.id}_${DateTime.now().millisecondsSinceEpoch}.png';
    final logoUrl = await _repository.uploadLogo(file, fileName);

    if (logoUrl != null) {
      final updatedEmployer = _employer!.copyWith(logoUrl: logoUrl);
      final success = await _repository.updateEmployerProfile(
        _employer!.id!,
        updatedEmployer,
      );

      if (success) {
        _employer = updatedEmployer;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
