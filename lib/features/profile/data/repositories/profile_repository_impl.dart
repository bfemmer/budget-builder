import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<Profile> getProfile() async {
    return await localDataSource.getProfile();
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    await localDataSource.updateProfile(profile);
  }
}
