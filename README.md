# Live Random - Vercel + Upstash

## Configuration obligatoire

1. Crée un compte gratuit sur https://upstash.com
2. Crée une base Redis
3. Copie `UPSTASH_REDIS_REST_URL` et `UPSTASH_REDIS_REST_TOKEN`
4. Dans Vercel → Settings → Environment Variables → ajoute les deux variables
5. Redéploie

Sans ces variables, le matching ne fonctionnera pas.
