const express = require('express');
const { Server } = require('socket.io');
const { v4: uuidv4 } = require('uuid');
const cors = require('cors');

const app = express();
app.use(cors({ origin: '*' }));

// Mémoire (limité sur Vercel)
let waiting = [];
const rooms = new Map();

function randomPseudo() {
  const prefixes = ["Night", "Void", "Neon", "Shadow", "Frost", "Blaze", "Echo", "Nova", "Ghost", "Pulse"];
  const suffixes = ["Wolf", "Fox", "Raven", "Viper", "Storm", "Blade", "Drift", "Spark", "Haze", "Zero"];
  return prefixes[Math.floor(Math.random() * prefixes.length)] + 
         suffixes[Math.floor(Math.random() * suffixes.length)] + 
         Math.floor(Math.random() * 90 + 10);
}

// On attache Socket.io seulement une fois
let io;

function getIO(server) {
  if (!io) {
    io = new Server(server, {
      cors: { origin: '*', methods: ['GET', 'POST'] },
      transports: ['websocket', 'polling'],
      path: '/socket.io'
    });

    io.on('connection', (socket) => {
      let currentRoom = null;
      let myPseudo = randomPseudo();

      socket.emit('pseudo', myPseudo);

      socket.on('find', () => {
        waiting = waiting.filter(u => u.id !== socket.id);

        if (waiting.length > 0) {
          const partner = waiting.shift();
          const roomId = uuidv4();

          currentRoom = roomId;
          partner.currentRoom = roomId;

          rooms.set(roomId, {
            users: [socket.id, partner.id]
          });

          socket.join(roomId);
          partner.join(roomId);

          socket.emit('matched', {
            roomId,
            partnerPseudo: partner.pseudo || 'Anonymous'
          });

          partner.emit('matched', {
            roomId,
            partnerPseudo: myPseudo
          });
        } else {
          socket.pseudo = myPseudo;
          waiting.push(socket);
          socket.emit('waiting');
        }
      });

      socket.on('next', () => {
        if (currentRoom) {
          socket.to(currentRoom).emit('partner_left');
          rooms.delete(currentRoom);
          socket.leave(currentRoom);
          currentRoom = null;
        }
        socket.emit('find');
      });

      socket.on('disconnect', () => {
        waiting = waiting.filter(u => u.id !== socket.id);
        if (currentRoom) {
          socket.to(currentRoom).emit('partner_left');
          rooms.delete(currentRoom);
        }
      });
    });
  }
  return io;
}

app.get('/', (req, res) => {
  res.send('Live Random Server is running on Vercel 🚀\n\nMatching is limited due to serverless architecture.');
});

// Handler principal pour Vercel
module.exports = (req, res) => {
  // Pour les upgrades WebSocket, on a besoin du serveur sous-jacent
  // Cette approche a des limitations sur Vercel
  const server = require('http').createServer(app);
  getIO(server);
  
  // Passe la requête à Express
  app(req, res);
};
