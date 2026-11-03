# MIHRAB | محراب

Application gratuite d'affichage des **horaires de prière et de l'adhan** pour les
mosquées et les maisons. Pensée pour **Android TV**, elle fonctionne aussi sur
téléphones et tablettes Android, et fonctionne **sans connexion Internet**.

## Fonctionnalités

**Affichage**
- Prochaine prière, compte à rebours et horaires du jour, date grégorienne + **date hégirienne**
- Interface adaptative : TV, tablette, téléphone (portrait et paysage), télécommande (D-pad + OK)
- 3 thèmes : Jamaa Okba (Kairouan), Masjid al-Haram (La Mecque), Qubbat al-Sakhra (Al-Qods)
- **3 langues** : arabe (RTL), français, anglais

**Prière**
- Adhan automatique (Fajr avec son propre adhan), volume réglable
- **Écran d'iqama** : compte à rebours après l'adhan, puis « alignez les rangs / éteignez vos téléphones »
- Délai d'iqama par prière et **ajustement ± minutes** de chaque horaire
- **Vendredi (Jumu'a)** : libellé dédié, délai propre, rappel (sourate Al-Kahf, salawat)
- **Mode Ramadan** : imsak, compte à rebours de l'iftar, taraweeh (automatique selon la date hégirienne, ou forcé)
- Verset, hadith et dhikr du jour, **inclus hors ligne**

**Mosquée**
- **Annonces défilantes** modifiables
- **Pilotage depuis le téléphone** : QR code affiché sur la TV → page web locale (même Wi-Fi) pour tout régler
- **Mode nuit** (écran sombre entre Isha et Fajr, réveil à la moindre touche)
- **Démarrage automatique** au boot de la TV (Android)

**Fiabilité hors ligne**
- Les horaires du mois en cours et du suivant sont téléchargés puis mis en cache (AlAdhan)
- Nouvelle tentative automatique avec délai croissant en cas d'échec réseau
- Indicateur réel de la dernière synchronisation
- Villes de Tunisie + grandes villes du monde, lieu personnalisé (coordonnées + fuseau), choix de la méthode de calcul

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

## Notes

- **Démarrage auto sur Android 10+** : activer « Affichage par-dessus les autres applications »
  (bouton dans Réglages > Écran et démarrage).
- **Pilotage par téléphone** : serveur HTTP local protégé par un code à 6 chiffres, uniquement sur le réseau local.
  Non disponible dans la version web.
- **Date hégirienne** : calendrier arithmétique, corrigeable de ± 2 jours dans les réglages
  (le début réel des mois dépend de l'observation de la lune).
- À faire : bannière Android TV (320x180) dédiée.

Développé par Fluttiris.
