import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local_settings_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({required this._dataSource});

  final LocalSettingsDataSource _dataSource;

  @override
  Future<AppSettings> getSettings() {
    return _dataSource.getSettings();
  }

  @override
  Future<void> saveSettings(AppSettings settings) {
    return _dataSource.saveSettings(settings);
  }
}
