import 'package:flutter/material.dart';
import '../../data/models/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository repository;

  ProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProfileViewModel({required this.repository});

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final p = await repository.getProfile();
      if (p is ProfileModel) {
        _profile = p;
      } else {
        _profile = ProfileModel(
          id: p.id,
          firstName: p.firstName,
          lastName: p.lastName,
          rank: p.rank,
          dutyStation: p.dutyStation,
          gender: p.gender,
          dateOfBirth: p.dateOfBirth,
          familySize: p.familySize,
          email: p.email,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(ProfileModel updatedProfile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.updateProfile(updatedProfile);
      _profile = updatedProfile;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
