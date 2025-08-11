/* eslint-disable object-curly-spacing */
/* eslint-disable require-jsdoc */
import { onCall } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

interface WordleGame {
  gameId: string;
  senderId: string;
  receiverId: string;
  word: string;
  guesses: string[];
  status: "pending" | "in_progress" | "won" | "lost";
  createdAt: FirebaseFirestore.Timestamp;
  updatedAt: FirebaseFirestore.Timestamp;
}

function generateGameId(): string {
  return db.collection("games").doc().id;
}

export const createGame = onCall(async (event) => {
  const { auth, data } = event;

  if (!auth?.uid) {
    throw new Error("unauthenticated: Must be logged in");
  }

  const { receiverId, word } = data;
  if (!receiverId || !word) {
    throw new Error("invalid-argument: Missing receiverId or word");
  }

  const gameId = generateGameId();

  const game: WordleGame = {
    gameId,
    senderId: auth.uid,
    receiverId,
    word: word.toLowerCase(),
    guesses: [],
    status: "pending",
    createdAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now(),
  };

  await db.collection("games").doc(gameId).set(game);

  return { gameId };
});

export const acceptGame = onCall(async (event) => {
  const { auth, data } = event;

  if (!auth?.uid) {
    throw new Error("unauthenticated: Must be logged in");
  }

  const { gameId } = data;
  if (!gameId) {
    throw new Error("invalid-argument: Missing gameId");
  }

  const gameRef = db.collection("games").doc(gameId);
  const gameSnap = await gameRef.get();

  if (!gameSnap.exists) {
    throw new Error("not-found: Game not found");
  }

  const game = gameSnap.data() as WordleGame;

  if (game.receiverId !== auth.uid) {
    throw new Error("permission-denied: Not your game");
  }

  await gameRef.update({
    status: "in_progress",
    updatedAt: admin.firestore.Timestamp.now(),
  });

  return { success: true };
});

/**
 * Delete old games (scheduled function)
 */
// export const cleanupOldGames = functions.pubsub
//   .schedule('every 24 hours')
//   .onRun(async () => {
//     const cutoff = admin.firestore.Timestamp.fromMillis(
//       Date.now() - 7 * 24 * 60 * 60 * 1000
//     );
//     const oldGames = await db
//       .collection('games')
//       .where('updatedAt', '<', cutoff)
//       .get();

//     const batch = db.batch();
//     oldGames.docs.forEach((doc) => batch.delete(doc.ref));
//     await batch.commit();

//     console.log(`Cleaned up ${oldGames.size} old games`);
//   });
