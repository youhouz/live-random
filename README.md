# Live Random

Application de matching vidéo live 100% aléatoire et anonyme.

- Matching instantané
- Swipe / Next
- Pseudos aléatoires
- **Aucune base de données** – tout est éphémère
- Aucune trace utilisateur

## Stack

- **Frontend** : Flutter (iOS + Android + Web)
- **Vidéo** : Agora RTC
- **Matching** : Node.js + Socket.io (100% en mémoire)
- **UI** : Dark premium + glassmorphism

## Structure

```
live-random/
├── server/               # Serveur de matching anonyme
│   ├── index.js
│   └── package.json
├── lib/                  # Application Flutter
│   ├── main.dart
│   ├── screens/
│   ├── services/
│   └── widgets/
└── pubspec.yaml
```

## Lancer le serveur

```bash
cd server
npm install
node index.js
```

## Lancer l'application Flutter

1. Crée un compte gratuit sur [agora.io](https://www.agora.io) et récupère ton App ID
2. Remplace `TON_AGORA_APP_ID` dans `lib/services/agora_service.dart`
3. Remplace l'IP du serveur dans `lib/services/socket_service.dart`
4. `flutter pub get`
5. `flutter run`

## Déploiement

- **Serveur** : Recommandé sur Railway, Render ou Fly.io (Vercel n'est pas idéal pour Socket.io longue durée)
- **Flutter Web** : Peut être déployé sur Vercel après `flutter build web`

## Licence

MIT
