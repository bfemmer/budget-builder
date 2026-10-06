import '../entities/profile.dart';
import '../../data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile();
  Future<void> updateProfile(ProfileModel profile);
}
