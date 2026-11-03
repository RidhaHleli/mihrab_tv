import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SaveAppSettings {
  const SaveAppSettings(this._repository);

  final SettingsRepository _repository;

  Future<void> call(AppSettings settings) {
    return _repository.saveSettings(settings);
  }
}
