# Live Random - Vercel Version

Application de matching vidéo live anonyme.

## Déploiement Vercel

1. Va sur [vercel.com](https://vercel.com)
2. Importe le repo `youhouz/live-random`
3. Laisse les settings par défaut
4. Deploy

Une fois déployé, tu auras une URL du type :
`https://live-random-xxxxx.vercel.app`

### Important

Sur Vercel le matching peut être **instable** car les instances ne partagent pas la mémoire.
Si deux personnes arrivent sur des instances différentes, elles ne se matchent pas.

Pour un matching fiable, utilise plutôt Railway ou Render.

## Flutter

Dans `lib/services/socket_service.dart`, mets l'URL Vercel :

```dart
socket = IO.io('https://TON-PROJET.vercel.app', {
  'transports': ['websocket', 'polling'],
  'autoConnect': true,
  'path': '/socket.io'
});
```
