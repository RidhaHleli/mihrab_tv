import '../../features/home/presentation/controllers/home_controller.dart';
import '../services/adhan_player_service.dart';
import '../theme/app_theme_controller.dart';
import '../theme/mihrab_palette.dart';

import '../../features/locations/data/datasources/local_locations_data_source.dart';
import '../../features/locations/data/repositories/locations_repository_impl.dart';
import '../../features/locations/domain/usecases/get_tunisia_locations.dart';
import '../../features/locations/presentation/controllers/locations_controller.dart';

import '../../features/prayer_times/data/datasources/local_prayer_times_data_source.dart';
import '../../features/prayer_times/data/datasources/remote_prayer_times_data_source.dart';
import '../../features/prayer_times/data/datasources/local_prayer_calendar_cache_data_source.dart';
import '../../features/prayer_times/data/repositories/prayer_times_repository_impl.dart';
import '../../features/prayer_times/domain/usecases/get_daily_prayer_times.dart';

import '../../features/settings/data/datasources/local_settings_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/usecases/get_app_settings.dart';
import '../../features/settings/domain/usecases/save_app_settings.dart';
import '../../features/settings/presentation/controllers/settings_controller.dart';

class InjectionContainer {
  InjectionContainer._();

  static HomeController createHomeController() {
    final settingsDataSource = LocalSettingsDataSource();

    final repository = PrayerTimesRepositoryImpl(
      dataSource: LocalPrayerTimesDataSource(),
      remoteDataSource: RemotePrayerTimesDataSource(),
      cacheDataSource: LocalPrayerCalendarCacheDataSource(),
      settingsDataSource: settingsDataSource,
    );

    final getDailyPrayerTimes = GetDailyPrayerTimes(repository);

    return HomeController(getDailyPrayerTimes);
  }

  /// Applies the saved theme before the first frame (avoids a colour flash).
  static Future<void> restoreTheme() async {
    try {
      final settings = await LocalSettingsDataSource().getSettings();
      AppThemeController.instance.value = AppThemeId.fromName(settings.themeId);
    } catch (_) {
      // Keep the default theme.
    }
  }

  static AdhanPlayerService createAdhanPlayerService() {
    return AdhanPlayerService();
  }

  static SettingsController createSettingsController() {
    final dataSource = LocalSettingsDataSource();
    final repository = SettingsRepositoryImpl(dataSource: dataSource);

    final getAppSettings = GetAppSettings(repository);
    final saveAppSettings = SaveAppSettings(repository);

    return SettingsController(
      getAppSettings: getAppSettings,
      saveAppSettings: saveAppSettings,
    );
  }

  static GetTunisiaLocations createGetTunisiaLocations() {
    final dataSource = LocalLocationsDataSource();
    final repository = LocationsRepositoryImpl(dataSource);

    return GetTunisiaLocations(repository);
  }

  static LocationsController createLocationsController() {
    final getLocations = createGetTunisiaLocations();

    return LocationsController(getLocations);
  }
}