import 'package:flutter/material.dart';
import 'package:jobgo/data/models/candidate_supabase_model.dart';
import 'package:jobgo/data/repositories/candidate_repository.dart';

class CandidateProvider extends ChangeNotifier {
  final CandidateRepository _repo = CandidateRepository();

  CandidateSupabaseModel? currentCandidate;
  bool isLoading = false;

  Future<void> loadCurrentCandidate() async {
    isLoading = true;
    notifyListeners();

    currentCandidate = await _repo.getCurrentCandidate();

    isLoading = false;
    notifyListeners();
  }
}
