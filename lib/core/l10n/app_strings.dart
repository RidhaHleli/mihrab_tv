import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Supported interface languages.
enum AppLanguage {
  ar('ar', 'العربية'),
  fr('fr', 'Français'),
  en('en', 'English');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.ar,
    );
  }
}

/// Active interface language, observed by the root widget.
class AppLocaleController extends ValueNotifier<String> {
  AppLocaleController._() : super('ar');

  static final AppLocaleController instance = AppLocaleController._();
}

/// Translates [key] into [languageCode] (falls back to the key itself).
String trFor(String languageCode, String key, {Map<String, String>? args}) {
  final entry = _strings[key];
  if (entry == null) return key;

  final index = AppLanguage.fromCode(languageCode).index;
  var value = entry[index];

  if (args != null) {
    args.forEach((name, replacement) {
      value = value.replaceAll('{$name}', replacement);
    });
  }

  return value;
}

extension AppStringsContext on BuildContext {
  String get languageCode => Localizations.localeOf(this).languageCode;

  String tr(String key, {Map<String, String>? args}) {
    return trFor(languageCode, key, args: args);
  }
}

/// Order of each list: Arabic, French, English.
const Map<String, List<String>> _strings = {
  // --- Home -------------------------------------------------------------
  'next_prayer': ['الصلاة القادمة', 'Prochaine prière', 'Next prayer'],
  'remaining': ['الوقت المتبقي', 'Temps restant', 'Time remaining'],
  'now_label': ['الوقت الآن', 'Heure actuelle', 'Time now'],
  'prayer_times': ['مواقيت الصلاة', 'Horaires de prière', 'Prayer times'],
  'today': ['اليوم', "Aujourd'hui", 'Today'],
  'unavailable': ['غير متاحة', 'Indisponible', 'Unavailable'],
  'offline_ok': ['يعمل دون إنترنت', 'Fonctionne hors ligne', 'Works offline'],
  'online_synced': ['متزامن', 'Synchronisé', 'Synced'],
  'last_update': ['آخر تحديث', 'Dernière mise à jour', 'Last update'],
  'syncing': ['جارٍ المزامنة...', 'Synchronisation...', 'Syncing...'],
  'never_synced': [
    'لم تتم المزامنة بعد',
    'Pas encore synchronisé',
    'Not synced yet',
  ],
  'loading_times': [
    'جارٍ تحميل مواقيت الصلاة...',
    'Chargement des horaires...',
    'Loading prayer times...',
  ],
  'load_error': [
    'تعذر تحميل مواقيت الصلاة.',
    'Impossible de charger les horaires.',
    'Unable to load prayer times.',
  ],
  'no_times': [
    'لم تتم إضافة مواقيت الصلاة لهذا التاريخ بعد.',
    'Aucun horaire pour cette date.',
    'No prayer times for this date yet.',
  ],
  'adhan_now': [
    'حان الآن وقت صلاة {p}',
    "C'est l'heure de la prière {p}",
    "It's time for {p} prayer",
  ],
  'settings': ['الإعدادات', 'Paramètres', 'Settings'],

  // --- Prayers ----------------------------------------------------------
  'fajr': ['الفجر', 'Fajr', 'Fajr'],
  'sunrise': ['الشروق', 'Lever du soleil', 'Sunrise'],
  'dhuhr': ['الظهر', 'Dhuhr', 'Dhuhr'],
  'asr': ['العصر', 'Asr', 'Asr'],
  'maghrib': ['المغرب', 'Maghrib', 'Maghrib'],
  'isha': ['العشاء', 'Isha', 'Isha'],
  'jumuah': ['الجمعة', "Joumou'a", "Jumu'ah"],

  // --- Iqama ------------------------------------------------------------
  'iqama_in': ['الإقامة بعد', 'Iqama dans', 'Iqama in'],
  'jumuah_in': [
    'الخطبة والصلاة بعد',
    'Khutba et prière dans',
    'Khutba & prayer in',
  ],
  'iqama_msg': [
    'سوّوا الصفوف وأغلقوا هواتفكم',
    'Alignez les rangs et éteignez vos téléphones',
    'Straighten the rows and silence your phones',
  ],
  'prayer_ongoing': [
    'الصلاة قائمة',
    'La prière est en cours',
    'Prayer in progress',
  ],
  'prayer_ongoing_msg': [
    'أغلقوا هواتفكم من فضلكم',
    "Merci d'éteindre vos téléphones",
    'Please silence your phones',
  ],
  'tap_to_close': ['اضغط للإغلاق', 'Appuyez pour fermer', 'Press to close'],

  // --- Ramadan / Friday / night ----------------------------------------
  'imsak': ['الإمساك', 'Imsak', 'Imsak'],
  'iftar': ['الإفطار', 'Iftar', 'Iftar'],
  'iftar_in': ['الإفطار بعد', 'Iftar dans', 'Iftar in'],
  'imsak_in': ['الإمساك بعد', 'Imsak dans', 'Imsak in'],
  'taraweeh': ['صلاة التراويح', 'Prière des Tarawih', 'Taraweeh prayer'],
  'ramadan_kareem': ['رمضان كريم', 'Ramadan Moubarak', 'Ramadan Mubarak'],
  'friday_banner': [
    'يوم الجمعة: أكثروا من الصلاة على النبي ﷺ واقرؤوا سورة الكهف',
    'Vendredi : multipliez les prières sur le Prophète ﷺ et lisez la sourate Al-Kahf',
    'Friday: send blessings upon the Prophet ﷺ and read Surat Al-Kahf',
  ],
  'night_hint': [
    'اضغط لإظهار الشاشة',
    "Appuyez pour réveiller l'écran",
    'Press to wake the screen',
  ],
  'rem_verse': ['آية اليوم', 'Verset du jour', 'Verse of the day'],
  'rem_hadith': ['حديث اليوم', 'Hadith du jour', 'Hadith of the day'],
  'rem_dhikr': ['ذكر اليوم', 'Dhikr du jour', 'Dhikr of the day'],

  // --- Themes -----------------------------------------------------------
  'theme_kairouan': [
    'جامع عقبة بن نافع',
    'Grande Mosquée de Kairouan',
    'Great Mosque of Kairouan',
  ],
  'theme_makkah': ['المسجد الحرام', 'Masjid al-Haram', 'Masjid al-Haram'],
  'theme_quds': ['قبة الصخرة', 'Dôme du Rocher', 'Dome of the Rock'],
  'sub_kairouan': ['القيروان', 'Kairouan', 'Kairouan'],
  'sub_makkah': ['مكة المكرمة', 'La Mecque', 'Makkah'],
  'sub_quds': ['القدس الشريف', 'Jérusalem', 'Jerusalem'],

  // --- Settings ---------------------------------------------------------
  'settings_title': ['إعدادات محراب', 'Paramètres MIHRAB', 'MIHRAB settings'],
  'appearance': ['المظهر', 'Apparence', 'Appearance'],
  'language': ['اللغة', 'Langue', 'Language'],
  'identity': [
    'هوية المسجد أو المنزل',
    'Nom de la mosquée ou de la maison',
    'Mosque or home name',
  ],
  'display_name': ['الاسم المعروض', 'Nom affiché', 'Display name'],
  'display_name_hint': [
    'مثال: مسجد الرحمة',
    'Ex. : Mosquée Al-Rahma',
    'e.g. Al-Rahma Mosque',
  ],
  'save_name': ['حفظ الاسم', 'Enregistrer le nom', 'Save name'],
  'name_saved': ['تم حفظ الاسم', 'Nom enregistré', 'Name saved'],
  'location': ['الموقع الجغرافي', 'Localisation', 'Location'],
  'location_saved': [
    'تم حفظ الموقع بنجاح',
    'Localisation enregistrée',
    'Location saved',
  ],
  'change_location': ['تغيير الموقع', 'Changer de lieu', 'Change location'],
  'calc_method': [
    'طريقة حساب المواقيت',
    'Méthode de calcul',
    'Calculation method',
  ],
  'adhan_section': ['الأذان والإقامة', 'Adhan et iqama', 'Adhan & iqama'],
  'adhan_on': ['تشغيل الأذان', "Jouer l'adhan", 'Play the adhan'],
  'adhan_on_sub': [
    'تشغيل صوت الأذان عند دخول وقت الصلاة',
    "Joue l'adhan à l'heure de chaque prière",
    'Plays the adhan when each prayer time starts',
  ],
  'iqama_on': ['شاشة الإقامة', "Écran d'iqama", 'Iqama screen'],
  'iqama_on_sub': [
    'عدّ تنازلي بعد الأذان ثم تنبيه بإغلاق الهواتف',
    "Compte à rebours après l'adhan puis rappel de silence",
    'Countdown after the adhan, then a silence reminder',
  ],
  'volume': ['مستوى الصوت', 'Volume', 'Volume'],
  'iqama_delays': [
    'الوقت بين الأذان والإقامة',
    "Délai entre l'adhan et l'iqama",
    'Time between adhan and iqama',
  ],
  'jumuah_delay': [
    'الخطبة والصلاة يوم الجمعة',
    'Khutba et prière du vendredi',
    'Friday khutba & prayer',
  ],
  'adjustments': [
    'تعديل أوقات الأذان',
    'Ajustement des horaires',
    'Prayer time adjustments',
  ],
  'adjustments_sub': [
    'زيادة أو نقصان بالدقائق لكل صلاة',
    'Minutes en plus ou en moins pour chaque prière',
    'Minutes added or removed for each prayer',
  ],
  'minutes_unit': ['د', 'min', 'min'],
  'announcements': ['الإعلانات', 'Annonces', 'Announcements'],
  'announcements_on': [
    'عرض الإعلانات',
    'Afficher les annonces',
    'Show announcements',
  ],
  'announcement_hint': [
    'اكتب إعلانًا جديدًا',
    'Saisir une nouvelle annonce',
    'Type a new announcement',
  ],
  'add': ['إضافة', 'Ajouter', 'Add'],
  'delete': ['حذف', 'Supprimer', 'Delete'],
  'no_announcements': ['لا توجد إعلانات', 'Aucune annonce', 'No announcements'],
  'reminders_on': [
    'آية وحديث وذكر اليوم',
    'Verset, hadith et dhikr du jour',
    'Daily verse, hadith and dhikr',
  ],
  'ramadan_section': [
    'رمضان والتاريخ الهجري',
    'Ramadan et date hégirienne',
    'Ramadan & Hijri date',
  ],
  'ramadan_mode': ['وضع رمضان', 'Mode Ramadan', 'Ramadan mode'],
  'mode_auto': ['تلقائي', 'Auto', 'Auto'],
  'mode_on': ['مفعّل', 'Activé', 'On'],
  'mode_off': ['متوقف', 'Désactivé', 'Off'],
  'hijri_adjust': [
    'تصحيح التاريخ الهجري (أيام)',
    'Correction de la date hégirienne (jours)',
    'Hijri date correction (days)',
  ],
  'imsak_minutes': [
    'الإمساك قبل الفجر (دقائق)',
    'Imsak avant le Fajr (min)',
    'Imsak before Fajr (min)',
  ],
  'screen_section': [
    'الشاشة والتشغيل',
    'Écran et démarrage',
    'Screen & startup',
  ],
  'night_mode': ['وضع الليل', 'Mode nuit', 'Night mode'],
  'night_mode_sub': [
    'شاشة هادئة بعد العشاء حتى قبل الفجر',
    "Écran sombre après l'Isha jusqu'avant le Fajr",
    'Dark screen after Isha until before Fajr',
  ],
  'autostart': [
    'التشغيل مع التلفاز',
    'Démarrage avec la TV',
    'Start with the TV',
  ],
  'autostart_sub': [
    'فتح التطبيق تلقائيًا عند تشغيل الجهاز (يتطلب إذن العرض فوق التطبيقات)',
    "Ouvre l'app au démarrage (autorisation « affichage par-dessus » requise)",
    'Opens the app when the device boots (needs "display over other apps")',
  ],
  'remote': [
    'التحكم من الهاتف',
    'Pilotage depuis le téléphone',
    'Phone remote control',
  ],
  'remote_sub': [
    'امسح الرمز بهاتفك المتصل بنفس الشبكة لتعديل الإعدادات',
    'Scannez le code avec un téléphone du même réseau pour modifier les réglages',
    'Scan with a phone on the same network to edit settings',
  ],
  'remote_url': ['الرابط', 'Lien', 'Link'],
  'remote_error': [
    'تعذر تشغيل خادم التحكم',
    'Impossible de démarrer le serveur',
    'Unable to start the remote server',
  ],
  'remote_no_network': [
    'لا توجد شبكة محلية',
    'Aucun réseau local',
    'No local network',
  ],
  'remote_saved': ['تم الحفظ', 'Enregistré', 'Saved'],
  'remote_unavailable': [
    'غير متاح على هذا الجهاز',
    'Indisponible sur cet appareil',
    'Not available on this device',
  ],

  'country_tn': ['تونس', 'Tunisie', 'Tunisia'],
  'method_auto': ['حسب المدينة', 'Selon la ville', 'By city'],

  'allow_overlay': [
    'السماح بالعرض فوق التطبيقات',
    "Autoriser l'affichage par-dessus les apps",
    'Allow display over other apps',
  ],
  'overlay_granted': [
    'إذن العرض فوق التطبيقات ممنوح',
    'Autorisation accordée',
    'Overlay permission granted',
  ],
  'notif_section': ['الإشعارات على الهاتف', 'Notifications sur téléphone', 'Phone notifications'],
  'notif_switch': ['أذان في الخلفية', "Adhan en arrière-plan", 'Adhan in the background'],
  'notif_sub': [
    'يرنّ الأذان حتى لو كان التطبيق مغلقاً',
    "L'adhan sonne même quand l'application est fermée",
    'The adhan rings even when the app is closed',
  ],
  'notif_body': ['حان الآن موعد الصلاة', "C'est l'heure de la prière", 'It is time to pray'],
  'notif_test': ['تجربة إشعار', 'Tester une notification', 'Send a test notification'],
  'notif_denied': [
    'الإشعارات مرفوضة: فعّلها من إعدادات النظام',
    'Notifications refusées : activez-les dans les réglages du système',
    'Notifications are blocked: enable them in system settings',
  ],
  'notif_channel': ['الأذان', 'Adhan', 'Adhan'],
  'scan_title': ['التحكم في شاشة التلفاز', 'Contrôler une TV', 'Control a TV'],
  'scan_sub': [
    'امسح رمز QR الظاهر على التلفاز لفتح لوحة التحكم',
    "Scannez le QR affiché sur la TV pour ouvrir la télécommande",
    'Scan the QR shown on the TV to open its remote control',
  ],
  'scan_button': ['مسح رمز QR', 'Scanner le QR', 'Scan QR code'],
  'scan_hint': ['وجّه الكاميرا نحو الرمز', 'Pointez la caméra vers le code', 'Point the camera at the code'],
  'scan_invalid': [
    'هذا الرمز ليس من MIHRAB على شبكتك',
    "Ce code ne vient pas d'un MIHRAB de votre réseau",
    'This code is not from a MIHRAB on your network',
  ],
  'scan_no_camera': [
    'الكاميرا غير متاحة، اسمح بالوصول إليها',
    "Caméra indisponible, autorisez son accès",
    'Camera unavailable, please allow access',
  ],
  'remote_code': ['رمز الاقتران', "Code d'appairage", 'Pairing code'],
  'about': ['حول التطبيق', 'À propos', 'About'],
  'about_text': [
    'تطبيق مجاني لعرض مواقيت الصلاة في المساجد والمنازل.',
    "Application gratuite d'affichage des horaires de prière pour mosquées et maisons.",
    'Free prayer-times display for mosques and homes.',
  ],

  // --- Locations --------------------------------------------------------
  'choose_city': ['اختر مدينتك', 'Choisissez votre ville', 'Choose your city'],
  'choose_city_sub': [
    'ستُستخدم هذه المعلومات لحساب مواقيت الصلاة بدقة.',
    'Ces informations servent à calculer les horaires avec précision.',
    'Used to calculate prayer times accurately.',
  ],
  'search_hint': [
    'ابحث عن مدينة أو دولة...',
    'Rechercher une ville ou un pays...',
    'Search a city or country...',
  ],
  'no_results': ['لا توجد نتائج', 'Aucun résultat', 'No results'],
  'location_title': ['اختيار الموقع', 'Choix du lieu', 'Choose location'],
  'custom_location': ['موقع مخصص', 'Lieu personnalisé', 'Custom location'],
  'custom_name': ['اسم المكان', 'Nom du lieu', 'Place name'],
  'latitude': ['خط العرض', 'Latitude', 'Latitude'],
  'longitude': ['خط الطول', 'Longitude', 'Longitude'],
  'timezone': [
    'المنطقة الزمنية (مثال: Europe/Paris)',
    'Fuseau horaire (ex. : Europe/Paris)',
    'Time zone (e.g. Europe/Paris)',
  ],
  'cancel': ['إلغاء', 'Annuler', 'Cancel'],
  'save': ['حفظ', 'Enregistrer', 'Save'],
  'invalid_values': ['قيم غير صحيحة', 'Valeurs invalides', 'Invalid values'],
  'load_locations_error': [
    'تعذر تحميل المواقع',
    'Impossible de charger les lieux',
    'Unable to load locations',
  ],
};

/// Weekday / month names for the date line.
abstract final class DateNames {
  static const weekdays = <String, List<String>>{
    'ar': [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ],
    'fr': [
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche',
    ],
    'en': [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ],
  };

  static const months = <String, List<String>>{
    'ar': [
      'جانفي',
      'فيفري',
      'مارس',
      'أفريل',
      'ماي',
      'جوان',
      'جويلية',
      'أوت',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ],
    'fr': [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ],
    'en': [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ],
  };

  static const hijriMonths = <String, List<String>>{
    'ar': [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الثاني',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ],
    'fr': [
      'Mouharram',
      'Safar',
      "Rabi' al-awwal",
      "Rabi' ath-thani",
      'Joumada al-oula',
      'Joumada ath-thania',
      'Rajab',
      'Chaabane',
      'Ramadan',
      'Chawwal',
      "Dhou al-qi'da",
      'Dhou al-hijja',
    ],
    'en': [
      'Muharram',
      'Safar',
      "Rabi' al-awwal",
      "Rabi' al-thani",
      'Jumada al-awwal',
      'Jumada al-thani',
      'Rajab',
      "Sha'ban",
      'Ramadan',
      'Shawwal',
      "Dhu al-Qi'dah",
      'Dhu al-Hijjah',
    ],
  };

  static List<String> _of(Map<String, List<String>> source, String lang) {
    return source[lang] ?? source['ar']!;
  }

  static String weekday(String lang, int weekday) =>
      _of(weekdays, lang)[weekday - 1];

  static String month(String lang, int month) => _of(months, lang)[month - 1];

  static String hijriMonth(String lang, int month) {
    final names = _of(hijriMonths, lang);
    return names[(month - 1).clamp(0, 11)];
  }
}
