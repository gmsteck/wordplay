/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { onCall } from "firebase-functions/https";

admin.initializeApp();
const db = admin.firestore();

// Types
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

/**
 * Generate a random ID for games
 */
function generateGameId(): string {
  return db.collection("games").doc().id;
}

/**
 * Create a new Wordle game
 * Triggered by HTTPS request from client
 */
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

/**
 * Accept a game invitation (start the game)
 */
export const acceptGame = onCall(async (event) => {
  const { auth, data } = event;
  if (!auth?.uid)
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Must be logged in"
    );

  const { gameId } = data;
  const gameRef = db.collection("games").doc(gameId);
  const gameSnap = await gameRef.get();

  if (!gameSnap.exists) {
    throw new functions.https.HttpsError("not-found", "Game not found");
  }

  const game = gameSnap.data() as WordleGame;
  if (game.receiverId !== auth.uid) {
    throw new functions.https.HttpsError("permission-denied", "Not your game");
  }

  await gameRef.update({
    status: "in_progress",
    updatedAt: admin.firestore.Timestamp.now(),
  });

  return { success: true };
});

/**
 * Submit a guess
 */
export const submitGuess = onCall(async (event) => {
  const { auth, data } = event;
  if (!auth?.uid)
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Must be logged in"
    );

  const { gameId, guess } = data;
  if (!guess || guess.length !== 5) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Guess must be 5 letters"
    );
  }

  const gameRef = db.collection("games").doc(gameId);
  const gameSnap = await gameRef.get();

  if (!gameSnap.exists)
    throw new functions.https.HttpsError("not-found", "Game not found");

  const game = gameSnap.data() as WordleGame;
  if (game.receiverId !== auth.uid) {
    throw new functions.https.HttpsError("permission-denied", "Not your turn");
  }
  if (game.status !== "in_progress") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Game not in progress"
    );
  }

  const updatedGuesses = [...game.guesses, guess.toLowerCase()];
  let newStatus = "in_progress";

  if (guess.toLowerCase() === game.word) {
    newStatus = "won";
  } else if (updatedGuesses.length >= 6) {
    newStatus = "lost";
  }

  await gameRef.update({
    guesses: updatedGuesses,
    status: newStatus,
    updatedAt: admin.firestore.Timestamp.now(),
  });

  return { status: newStatus, guesses: updatedGuesses };
});

/**
 * Get the current game state
 */
export const getGameState = onCall(async (event) => {
  const { auth, data } = event;
  if (!auth?.uid)
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Must be logged in"
    );

  const { gameId } = data;
  const gameSnap = await db.collection("games").doc(gameId).get();

  if (!gameSnap.exists)
    throw new functions.https.HttpsError("not-found", "Game not found");

  const game = gameSnap.data() as WordleGame;
  if (![game.senderId, game.receiverId].includes(auth.uid)) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Not part of this game"
    );
  }

  return {
    ...game,
    createdAt: game.createdAt.toDate().toISOString(),
    updatedAt: game.updatedAt.toDate().toISOString(),
  };
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
