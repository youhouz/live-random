const express = require('express');
const { Server } = require('socket.io');
const { v4: uuidv4 } = require('uuid');
const cors = require('cors');
const { Redis } = require('@upstash/redis');

const app = express();
app.use(cors({ origin: '*' }));

// Redis partagé (obligatoire pour Vercel)
const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL,
  token: process.env.UPSTASH_REDIS_REST_TOKEN,
});

const WAITING_KEY = 'live:waiting';

function randomPseudo() {
  const prefixes = ["Night", "Void", "Neon", "Shadow", "Frost", "Blaze", "Echo", "Nova", "Ghost", "Pulse"];
  const suffixes = ["Wolf", "Fox", "Raven", "Viper", "Storm", "Blade", "Drift", "Spark", "Haze", "Zero"];
  return prefixes[Math.floor(Math.random() * prefixes.length)] +
         suffixes[Math.floor(Math.random() * suffixes.length)] +
         Math.floor(Math.random() * 90 + 10);
}

let io = null;

function initIO(server) {
  if (io) return io;

  io = new Server(server, {
    cors: { origin: '*', methods: ['GET', 'POST'] },
    transports: ['websocket', 'polling'],
    path: '/socket.io'
  });

  io.on('connection', (socket) => {
    let myPseudo = randomPseudo();
    let currentRoom = null;

    socket.emit('pseudo', myPseudo);

    socket.on('find', async () => {
      try {
        // Retire de la file s'il y était
        await redis.lrem(WAITING_KEY, 0, socket.id);

        // Essaie de prendre quelqu'un en attente
        const partnerId = await redis.lpop(WAITING_KEY);

        if (partnerId) {
          const roomId = uuidv4();
          currentRoom = roomId;

          // Informe les deux
          socket.emit('matched', {
            roomId,
            partnerPseudo: 'Anonymous'
          });

          // On essaie d'émettre à l'autre (si sur la même instance)
          io.to(partnerId).emit('matched', {
            roomId,
            partnerPseudo: myPseudo
          });

          // Stocke la room temporairement
          await redis.set(`room:${roomId}`, JSON.stringify([socket.id, partnerId]), { ex: 300 });

        } else {
          // Personne → on se met en file
          await redis.rpush(WAITING_KEY, socket.id);
          await redis.expire(WAITING_KEY, 60); // expire après 60s
          socket.emit('waiting');
        }
      } catch (err) {
        console.error(err);
        socket.emit('waiting');
      }
    });

    socket.on('next', async () => {
      if (currentRoom) {
        await redis.del(`room:${currentRoom}`);
        currentRoom = null;
      }
      socket.emit('find');
    });

    socket.on('disconnect', async () => {
      await redis.lrem(WAITING_KEY, 0, socket.id);
      if (currentRoom) {
        await redis.del(`room:${currentRoom}`);
      }
    });
  });

  return io;
}

app.get('/', (req, res) => {
  res.send('Live Random Server running on Vercel + Upstash Redis');
});

module.exports = (req, res) => {
  // Note: Socket.io sur Vercel reste limité (durée + instances)
  // Mais avec Redis la file d\'attente est partagée
  const server = require('http').createServer(app);
  initIO(server);
  app(req, res);
};
