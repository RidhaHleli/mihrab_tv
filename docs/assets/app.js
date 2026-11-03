(function () {
  'use strict';

  /* ---------- Translations ---------- */
  var T = {
    fr: {
      skip: 'Aller au contenu', nav_features: 'Fonctions', nav_phone: 'Téléphone', nav_install: 'Installer',
      h1: "L'heure de la prière, sur l'écran de la mosquée.",
      lead: "MIHRAB affiche les horaires, joue l'adhan, annonce l'iqama et fait défiler vos annonces. Gratuit, sans compte, même sans Internet.",
      cta_dl: "Télécharger l'APK", cta_src: 'Voir le code source',
      fine: 'Android TV, tablette et téléphone · arabe, français, anglais',
      t_kairouan: 'Kairouan', t_makkah: 'La Mecque', t_quds: 'Al-Qods',
      demo_note: "Aperçu animé à l'heure de votre appareil, avec des horaires d'exemple.",
      f_title: 'Ce que MIHRAB fait pour votre mosquée',
      g1: 'Autour de la prière',
      g1a: 'Adhan automatique', g1a_t: 'Fajr avec son propre adhan, volume réglable.',
      g1b: "Écran d'iqama", g1b_t: 'Compte à rebours, puis « alignez les rangs, éteignez vos téléphones ».',
      g1c: 'Réglages fins', g1c_t: "Délai d'iqama par prière, horaires ajustables de plus ou moins 30 minutes.",
      g1d: 'Vendredi', g1d_t: "Délai propre à la Jumu'a et rappel de sourate Al-Kahf.",
      g2: 'Pour la communauté',
      g2a: 'Annonces défilantes', g2a_t: 'Cours, funérailles, collectes : modifiables à tout moment.',
      g2b: 'Mode Ramadan', g2b_t: "Imsak, compte à rebours de l'iftar, taraweeh.",
      g2c: 'Verset, hadith, dhikr', g2c_t: "Un nouveau rappel chaque jour, inclus dans l'application.",
      g2d: 'Date hégirienne', g2d_t: "Corrigeable de deux jours selon l'observation de la lune.",
      g3: 'Fiable au quotidien',
      g3a: 'Fonctionne hors ligne', g3a_t: 'Les horaires du mois sont téléchargés puis gardés en mémoire.',
      g3b: 'Mode nuit', g3b_t: 'Écran sombre entre Isha et Fajr, réveil à la moindre touche.',
      g3c: 'Démarrage automatique', g3c_t: "L'application s'ouvre seule quand la TV s'allume.",
      g3d: 'Partout dans le monde', g3d_t: 'Villes de Tunisie, grandes villes, lieu personnalisé, 21 méthodes de calcul.',
      p_title: 'Réglez tout depuis votre téléphone',
      p_text: "Un QR code s'affiche sur la TV. Scannez-le avec un téléphone connecté au même Wi-Fi : changez une annonce, un horaire ou la langue sans télécommande. Rien ne passe par Internet.",
      ph_adhan: 'Adhan', ph_iqama: 'Iqama', ph_night: 'Mode nuit', ph_ann: 'Cours de tajwid après Maghrib', ph_save: 'Enregistrer',
      i_title: 'Installer sur la TV de la mosquée',
      i1: "Téléchargez le fichier APK depuis la page des versions GitHub.",
      i2: "Copiez-le sur une clé USB, ou installez « Downloader » sur la TV et saisissez le lien.",
      i3: "Ouvrez l'application, choisissez la ville et le nom de la mosquée dans les réglages.",
      i4: "Autorisez « Affichage par-dessus les autres applications » pour le démarrage automatique.",
      made: 'Créé par', free: 'application gratuite pour les mosquées et les familles.'
    },
    en: {
      skip: 'Skip to content', nav_features: 'Features', nav_phone: 'Phone', nav_install: 'Install',
      h1: "Prayer time, on the mosque's screen.",
      lead: 'MIHRAB shows the timetable, plays the adhan, announces the iqama and scrolls your announcements. Free, no account, works without Internet.',
      cta_dl: 'Download the APK', cta_src: 'View the source code',
      fine: 'Android TV, tablet and phone · Arabic, French, English',
      t_kairouan: 'Kairouan', t_makkah: 'Makkah', t_quds: 'Al-Quds',
      demo_note: "Live preview using your device's clock, with sample prayer times.",
      f_title: 'What MIHRAB does for your mosque',
      g1: 'Around the prayer',
      g1a: 'Automatic adhan', g1a_t: 'Fajr has its own adhan; volume is adjustable.',
      g1b: 'Iqama screen', g1b_t: 'A countdown, then "straighten the rows, silence your phones".',
      g1c: 'Fine tuning', g1c_t: 'Iqama delay per prayer, times adjustable by up to 30 minutes either way.',
      g1d: 'Friday', g1d_t: "Its own Jumu'ah delay and a reminder to read Surat Al-Kahf.",
      g2: 'For the community',
      g2a: 'Scrolling announcements', g2a_t: 'Classes, funerals, collections: editable at any time.',
      g2b: 'Ramadan mode', g2b_t: 'Imsak, iftar countdown, taraweeh.',
      g2c: 'Verse, hadith, dhikr', g2c_t: 'A new reminder every day, built into the app.',
      g2d: 'Hijri date', g2d_t: 'Adjustable by two days to follow the moon sighting.',
      g3: 'Reliable every day',
      g3a: 'Works offline', g3a_t: "The month's timetable is downloaded, then kept on the device.",
      g3b: 'Night mode', g3b_t: 'A dark screen between Isha and Fajr; any key wakes it.',
      g3c: 'Automatic start', g3c_t: 'The app opens by itself when the TV turns on.',
      g3d: 'Anywhere in the world', g3d_t: 'Tunisian towns, major cities, custom places, 21 calculation methods.',
      p_title: 'Change everything from your phone',
      p_text: 'A QR code appears on the TV. Scan it with a phone on the same Wi-Fi: edit an announcement, a time or the language without a remote. Nothing goes through the Internet.',
      ph_adhan: 'Adhan', ph_iqama: 'Iqama', ph_night: 'Night mode', ph_ann: 'Tajweed class after Maghrib', ph_save: 'Save',
      i_title: "Install on the mosque's TV",
      i1: 'Download the APK file from the GitHub releases page.',
      i2: 'Copy it to a USB stick, or install "Downloader" on the TV and type the link.',
      i3: 'Open the app and pick the city and the mosque name in the settings.',
      i4: 'Allow "Display over other apps" so the app can start automatically.',
      made: 'Made by', free: 'a free app for mosques and families.'
    },
    ar: {
      skip: 'انتقل إلى المحتوى', nav_features: 'المزايا', nav_phone: 'الهاتف', nav_install: 'التثبيت',
      h1: 'وقت الصلاة على شاشة المسجد.',
      lead: 'يعرض محراب مواقيت الصلاة، ويرفع الأذان، وينبّه بإقامة الصلاة، ويُمرّر إعلانات المسجد. مجاني، بلا حساب، ويعمل دون إنترنت.',
      cta_dl: 'تحميل ملف APK', cta_src: 'عرض الشيفرة المصدرية',
      fine: 'أندرويد تي في والأجهزة اللوحية والهواتف · العربية والفرنسية والإنجليزية',
      t_kairouan: 'القيروان', t_makkah: 'مكة المكرمة', t_quds: 'القدس',
      demo_note: 'معاينة حيّة بتوقيت جهازك مع مواقيت تجريبية.',
      f_title: 'ماذا يقدّم محراب لمسجدك',
      g1: 'حول الصلاة',
      g1a: 'أذان تلقائي', g1a_t: 'للفجر أذانه الخاص، ومستوى الصوت قابل للضبط.',
      g1b: 'شاشة الإقامة', g1b_t: 'عدّ تنازلي ثم «سوّوا الصفوف وأغلقوا هواتفكم».',
      g1c: 'ضبط دقيق', g1c_t: 'مدة الإقامة لكل صلاة، وتعديل المواقيت بزيادة أو نقصان حتى ٣٠ دقيقة.',
      g1d: 'يوم الجمعة', g1d_t: 'مدة خاصة بالجمعة وتذكير بقراءة سورة الكهف.',
      g2: 'من أجل الجماعة',
      g2a: 'إعلانات متحركة', g2a_t: 'دروس وجنائز وتبرعات، تعدّلها متى شئت.',
      g2b: 'وضع رمضان', g2b_t: 'الإمساك، وعدّ تنازلي للإفطار، والتراويح.',
      g2c: 'آية وحديث وذكر', g2c_t: 'تذكير جديد كل يوم، مدمج في التطبيق.',
      g2d: 'التاريخ الهجري', g2d_t: 'يمكن تصحيحه بيومين حسب رؤية الهلال.',
      g3: 'موثوق كل يوم',
      g3a: 'يعمل دون إنترنت', g3a_t: 'تُحمَّل مواقيت الشهر ثم تُحفظ على الجهاز.',
      g3b: 'وضع الليل', g3b_t: 'شاشة مظلمة بين العشاء والفجر، وأي زر يوقظها.',
      g3c: 'تشغيل تلقائي', g3c_t: 'يفتح التطبيق وحده عند تشغيل التلفاز.',
      g3d: 'في كل مكان من العالم', g3d_t: 'مدن تونسية وعواصم كبرى ومواقع مخصّصة و٢١ طريقة حساب.',
      p_title: 'اضبط كل شيء من هاتفك',
      p_text: 'يظهر رمز QR على التلفاز. امسحه بهاتف متصل بنفس شبكة الواي فاي لتعديل إعلان أو موعد أو اللغة دون جهاز تحكم. لا شيء يمرّ عبر الإنترنت.',
      ph_adhan: 'الأذان', ph_iqama: 'الإقامة', ph_night: 'وضع الليل', ph_ann: 'درس تجويد بعد المغرب', ph_save: 'حفظ',
      i_title: 'التثبيت على تلفاز المسجد',
      i1: 'حمّل ملف APK من صفحة الإصدارات على GitHub.',
      i2: 'انسخه على قرص USB، أو ثبّت تطبيق «Downloader» على التلفاز وأدخل الرابط.',
      i3: 'افتح التطبيق واختر المدينة واسم المسجد من الإعدادات.',
      i4: 'فعّل «العرض فوق التطبيقات الأخرى» ليبدأ التطبيق تلقائيًا.',
      made: 'من تطوير', free: 'تطبيق مجاني للمساجد والعائلات.'
    }
  };

  var TV = {
    fr: { mosque: 'Mosquée Al-Rahma', city: 'Kairouan, Tunisie', next: 'Prochaine prière', rem: 'Temps restant',
      names: ['Fajr', 'Lever du soleil', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'],
      ticker: "✦ Prière du vendredi 30 minutes après l'adhan ✦ Cours de tajwid après Maghrib ✦" },
    en: { mosque: 'Al-Rahma Mosque', city: 'Kairouan, Tunisia', next: 'Next prayer', rem: 'Time remaining',
      names: ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'],
      ticker: '✦ Friday prayer starts 30 minutes after the adhan ✦ Tajweed class after Maghrib ✦' },
    ar: { mosque: 'مسجد الرحمة', city: 'القيروان، تونس', next: 'الصلاة القادمة', rem: 'الوقت المتبقي',
      names: ['الفجر', 'الشروق', 'الظهر', 'العصر', 'المغرب', 'العشاء'],
      ticker: '✦ صلاة الجمعة بعد الأذان بثلاثين دقيقة ✦ درس تجويد بعد صلاة المغرب ✦' }
  };

  // Sample timetable (hh, mm). Sunrise is shown but is never "next".
  var TIMES = [[5, 12], [6, 41], [12, 8], [15, 9], [17, 31], [18, 52]];

  var lang = 'ar';

  function pad(n) { return (n < 10 ? '0' : '') + n; }
  function hhmm(t) { return pad(t[0]) + ':' + pad(t[1]); }

  /* ---------- Language ---------- */
  function applyLang(code) {
    if (!T[code]) code = 'ar';
    lang = code;
    var root = document.documentElement;
    root.lang = code;
    root.dir = code === 'ar' ? 'rtl' : 'ltr';

    document.querySelectorAll('[data-i18n]').forEach(function (el) {
      var v = T[code][el.getAttribute('data-i18n')];
      if (v) el.textContent = v;
    });

    document.querySelectorAll('.lang button').forEach(function (b) {
      b.setAttribute('aria-pressed', String(b.getAttribute('data-lang') === code));
    });

    var s = TV[code];
    document.getElementById('s-mosque').textContent = s.mosque;
    document.getElementById('s-city').textContent = s.city;
    document.getElementById('s-next-label').textContent = s.next;
    document.getElementById('s-rem-label').textContent = s.rem;
    document.getElementById('s-ticker').textContent = s.ticker + ' ' + s.ticker;
    document.getElementById('screen').setAttribute('aria-label', s.mosque + ' · ' + s.next);

    try { localStorage.setItem('mihrab-lang', code); } catch (e) { /* private mode */ }
    renderTv();
  }

  function initialLang() {
    try {
      var saved = localStorage.getItem('mihrab-lang');
      if (saved && T[saved]) return saved;
    } catch (e) { /* ignore */ }
    var nav = (navigator.language || 'ar').slice(0, 2);
    return T[nav] ? nav : 'ar';
  }

  /* ---------- TV preview ---------- */
  function renderTv() {
    var now = new Date();
    var nowMin = now.getHours() * 60 + now.getMinutes() + now.getSeconds() / 60;
    var names = TV[lang].names;

    var nextIdx = -1;
    for (var i = 0; i < TIMES.length; i++) {
      if (i === 1) continue;
      if (TIMES[i][0] * 60 + TIMES[i][1] > nowMin) { nextIdx = i; break; }
    }
    var tomorrow = nextIdx === -1;
    if (tomorrow) nextIdx = 0;

    var target = new Date(now.getFullYear(), now.getMonth(), now.getDate() + (tomorrow ? 1 : 0),
      TIMES[nextIdx][0], TIMES[nextIdx][1], 0);
    var diff = Math.max(0, Math.floor((target - now) / 1000));
    var h = Math.floor(diff / 3600), m = Math.floor((diff % 3600) / 60), sec = diff % 60;

    document.getElementById('s-clock').textContent = pad(now.getHours()) + ':' + pad(now.getMinutes());
    document.getElementById('s-next').textContent = names[nextIdx];
    document.getElementById('s-next-time').textContent = hhmm(TIMES[nextIdx]);
    document.getElementById('s-count').textContent = pad(h) + ' : ' + pad(m) + ' : ' + pad(sec);

    var grid = document.getElementById('s-grid');
    if (grid.children.length !== TIMES.length) {
      grid.textContent = '';
      TIMES.forEach(function () {
        var li = document.createElement('li');
        li.appendChild(document.createElement('b'));
        li.appendChild(document.createElement('span')).setAttribute('dir', 'ltr');
        grid.appendChild(li);
      });
    }
    TIMES.forEach(function (t, idx) {
      var li = grid.children[idx];
      li.firstChild.textContent = names[idx];
      li.lastChild.textContent = hhmm(t);
      var passed = !tomorrow ? (t[0] * 60 + t[1] <= nowMin) : true;
      li.className = idx === nextIdx ? 'next' : (passed ? 'past' : '');
    });
  }

  /* ---------- Decorative QR-like pattern (not a real code) ---------- */
  function drawQr() {
    var size = 21, d = '', seed = 7;
    function rnd() { seed = (seed * 1103515245 + 12345) & 0x7fffffff; return seed / 0x7fffffff; }
    function finder(x, y) {
      for (var i = 0; i < 7; i++) for (var j = 0; j < 7; j++) {
        var edge = i === 0 || j === 0 || i === 6 || j === 6;
        var core = i >= 2 && i <= 4 && j >= 2 && j <= 4;
        if (edge || core) d += 'M' + (x + i) + ' ' + (y + j) + 'h1v1h-1z';
      }
    }
    function inFinder(x, y) {
      return (x < 8 && y < 8) || (x > size - 9 && y < 8) || (x < 8 && y > size - 9);
    }
    for (var y = 0; y < size; y++) for (var x = 0; x < size; x++) {
      if (!inFinder(x, y) && rnd() > 0.52) d += 'M' + x + ' ' + y + 'h1v1h-1z';
    }
    finder(0, 0); finder(size - 7, 0); finder(0, size - 7);
    document.getElementById('qrpath').setAttribute('d', d);
  }

  /* ---------- Theme buttons ---------- */
  document.querySelectorAll('.themes button').forEach(function (b) {
    b.addEventListener('click', function () {
      document.getElementById('tv').setAttribute('data-theme', b.getAttribute('data-theme'));
      document.querySelectorAll('.themes button').forEach(function (o) {
        o.setAttribute('aria-pressed', String(o === b));
      });
    });
  });

  document.querySelectorAll('.lang button').forEach(function (b) {
    b.addEventListener('click', function () { applyLang(b.getAttribute('data-lang')); });
  });

  // If a real screenshot is added as assets/screen.png, show it on the TV.
  var probe = new Image();
  probe.onload = function () {
    probe.className = 'shot';
    probe.alt = '';
    document.getElementById('screen').appendChild(probe);
  };
  probe.src = 'assets/screen.png';

  drawQr();
  applyLang(initialLang());
  setInterval(renderTv, 1000);
})();
