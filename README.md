# MIHRAB | محراب

Application gratuite d'affichage des **horaires de prière et de l'adhan** pour les
mosquées et les maisons. Pensée pour **Android TV**, elle fonctionne aussi sur
téléphones et tablettes Android, et fonctionne **sans connexion Internet**.

## Fonctionnalités

- Prochaine prière, compte à rebours et horaires du jour
- Adhan joué automatiquement à l'heure de chaque prière (Fajr avec son propre adhan)
- Interface adaptative : TV, tablette, téléphone (portrait et paysage)
- Navigation à la télécommande (D-pad + OK) avec focus visible
- 3 thèmes au choix : Jamaa Okba (Kairouan), Masjid al-Haram (La Mecque), Qubbat al-Sakhra (Al-Qods)
- Choix de la ville (Tunisie), nom de la mosquée/maison, volume
- Interface en arabe (RTL)

## Lancer le projet

```bash
flutter pub get
flutter run            # appareil ou émulateur Android / Android TV
flutter run -d chrome  # aperçu rapide sur le web
flutter analyze
flutter test
```

## Architecture

Architecture par fonctionnalité (`lib/features/*`) avec couches
`data` / `domain` / `presentation`, et un noyau partagé dans `lib/core`
(thème, responsive, services, widgets).

## À venir

- Iqama (l'option existe dans les réglages mais n'est pas encore implémentée)
- Démarrage automatique au boot de la TV
- Bannière Android TV (320x180) et police arabe embarquée

Développé par Fluttiris.
