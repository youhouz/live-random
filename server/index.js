const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const { v4: uuidv4 } = require('uuid');
const cors = require('cors');

const app = express();
app.use(cors());
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*" },
  transports: ['websocket']
});

// === MÉMOIRE UNIQUEMENT - AUCUNE BASE DE DONNÉES ===
let waiting = [];
const rooms = new Map();

function randomPseudo() {
  const prefixes = ["Night", "Void", "Neon", "Shadow", "Frost", "Blaze", "Echo", "Nova", "Ghost", "Pulse"];
  const suffixes = ["Wolf", "Fox", "Raven", "Viper", "Storm", "Blade", "Drift", "Spark", "Haze", "Zero"];
  return `${prefixes[Math.floor(Math.random()*prefixes.length)]}${suffixes[Math.floor(Math.random()*suffixes.length)]}${Math.floor(Math.random()*90+10)}`;
}

io.on('connection', (socket) => {
  let currentRoom = null;
  let myPseudo = randomPseudo();

  socket.emit('pseudo', myPseudo);

  socket.on('find', () => {
    cleanWaiting(socket.id);

    if (waiting.length > 0) {
      const partner = waiting.shift();
      const roomId = uuidv4();

      currentRoom = roomId;
      partner.currentRoom = roomId;

      rooms.set(roomId, {
        users: [socket.id, partner.id],
        pseudos: { [socket.id]: myPseudo, [partner.id]: partner.pseudo }
      });

      socket.join(roomId);
      partner.join(roomId);

      socket.emit('matched', {
        roomId,
        partnerPseudo: partner.pseudo
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
    leaveRoom(socket);
    // Relance la recherche
    socket.emit('find');
  });

  socket.on('disconnect', () => {
    leaveRoom(socket);
    cleanWaiting(socket.id);
  });

  function leaveRoom(s) {
    if (!s.currentRoom) return;
    const room = rooms.get(s.currentRoom);
    if (room) {
      s.to(s.currentRoom).emit('partner_left');
      rooms.delete(s.currentRoom);
    }
    s.leave(s.currentRoom);
    s.currentRoom = null;
  }

  function cleanWaiting(id) {
    waiting = waiting.filter(u => u.id !== id);
  }
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🔥 Serveur anonyme live lancé → port ${PORT}`);
});
