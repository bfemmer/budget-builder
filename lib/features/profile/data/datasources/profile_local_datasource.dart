import 'package:sqflite/sqflite.dart';
import '../../../../core/sqlite/database_helper.dart';
import '../../../../core/sqlite/tables.dart';
import '../models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel> getProfile();
  Future<void> updateProfile(ProfileModel profile);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final DatabaseHelper dbHelper;

  ProfileLocalDataSourceImpl({required this.dbHelper});

  @override
  Future<ProfileModel> getProfile() async {
    final db = await dbHelper.database;
    final maps = await db.query(DbTables.profile, limit: 1);
    if (maps.isNotEmpty) {
      return ProfileModel.fromMap(maps.first);
    }
    // Return default fallback if empty
    return ProfileModel.fromMap(DbTables.defaultProfile);
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    final db = await dbHelper.database;
    await db.insert(
      DbTables.profile,
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
