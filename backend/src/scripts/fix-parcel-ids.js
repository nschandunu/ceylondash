/**
 * One-time fix: corrects the test parcel document so senderId and receiverId
 * are proper ObjectIds instead of plain strings / Firebase UIDs.
 *
 * Run from the backend directory:
 *   node src/scripts/fix-parcel-ids.js
 */

require("dotenv").config();
const mongoose = require("mongoose");

const PARCEL_ID = "699c088715063e647bf213d9";
const USER_OID  = "699c2af1ef3ab8fcb5e9c37b"; // Test User's MongoDB _id

async function run() {
  await mongoose.connect(process.env.MONGO_URI);
  console.log("Connected to database:", mongoose.connection.db.databaseName);

  const db = mongoose.connection.db;
  const parcels = db.collection("parcels");

  const userOid = new mongoose.Types.ObjectId(USER_OID);
  const parcelOid = new mongoose.Types.ObjectId(PARCEL_ID);

  const result = await parcels.updateOne(
    { _id: parcelOid },
    {
      $set: {
        senderId:   userOid,  // ObjectId instead of string
        receiverId: userOid,  // ObjectId instead of Firebase UID
      },
    }
  );

  if (result.matchedCount === 0) {
    console.log("❌ Parcel not found.");
  } else if (result.modifiedCount === 0) {
    console.log("ℹ️  Parcel already had correct values.");
  } else {
    console.log("✅ Parcel updated:");
    console.log(`   senderId  → ObjectId("${USER_OID}")`);
    console.log(`   receiverId→ ObjectId("${USER_OID}")`);
  }

  process.exit(0);
}

run().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});
