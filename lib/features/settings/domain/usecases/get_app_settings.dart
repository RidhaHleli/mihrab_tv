import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetAppSettings {
  const GetAppSettings(this._repository);

  final SettingsRepository _repository;

  Future<AppSettings> call() {
    return _repository.getSettings();
  }
}
