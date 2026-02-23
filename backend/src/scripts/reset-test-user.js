/**
 * One-time dev script: recreates the Firebase Auth test user with the
 * original UID so it matches the `firebaseUid` in MongoDB.
 *
 * Run once from the backend directory:
 *   node src/scripts/reset-test-user.js
 */

require("dotenv").config();
const admin = require("../config/firebase");

const TARGET_UID = "hB4UnEDz9CRXeOndWpuUm0fKzZ63";
const TARGET_EMAIL = "testmail@example.com";
const TARGET_PASSWORD = "123456";

async function run() {
  // 1. Delete any existing user with this email (may have a different UID)
  try {
    const existing = await admin.auth().getUserByEmail(TARGET_EMAIL);
    if (existing.uid !== TARGET_UID) {
      await admin.auth().deleteUser(existing.uid);
      console.log(`Deleted existing user with UID: ${existing.uid}`);
    } else {
      console.log("User already exists with the correct UID. Nothing to do.");
      process.exit(0);
    }
  } catch (e) {
    if (e.code !== "auth/user-not-found") throw e;
    console.log("No existing user found — will create fresh.");
  }

  // 2. Create user with the exact original UID
  const user = await admin.auth().createUser({
    uid: TARGET_UID,
    email: TARGET_EMAIL,
    password: TARGET_PASSWORD,
    emailVerified: false,
  });

  console.log(`✅ Test user recreated with UID: ${user.uid}`);
  console.log(`   Email   : ${user.email}`);
  console.log(`   Password: ${TARGET_PASSWORD}`);
  console.log("MongoDB firebaseUid is already correct — no DB changes needed.");
  process.exit(0);
}

run().catch((err) => {
  console.error("❌ Failed:", err.message);
  process.exit(1);
});
