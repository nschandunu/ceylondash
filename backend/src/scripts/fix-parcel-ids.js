/**
 * Fix script: converts all parcels that have senderId/receiverId stored as
 * plain strings (or Firebase UIDs) into proper ObjectIds.
 *
 * Run from the backend directory:
 *   node src/scripts/fix-parcel-ids.js
 */

require("dotenv").config();
const mongoose = require("mongoose");

// The test user's MongoDB _id — used as fallback when receiverId is not a
// valid ObjectId (e.g. a Firebase UID was accidentally stored there).
const FALLBACK_USER_OID = "699c2af1ef3ab8fcb5e9c37b";

async function run() {
  await mongoose.connect(process.env.MONGO_URI);
  console.log("Connected to database:", mongoose.connection.db.databaseName);

  const db = mongoose.connection.db;
  const parcels = db.collection("parcels");

  const allParcels = await parcels.find({}).toArray();
  console.log(`Found ${allParcels.length} parcel(s). Checking…\n`);

  let fixed = 0;

  for (const parcel of allParcels) {
    const updates = {};

    // Fix senderId if stored as a plain string
    if (typeof parcel.senderId === "string") {
      try {
        updates.senderId = new mongoose.Types.ObjectId(parcel.senderId);
      } catch {
        console.warn(`  ⚠ Parcel ${parcel._id}: senderId "${parcel.senderId}" is not a valid ObjectId — skipping`);
      }
    }

    // Fix receiverId if it's a string (plain string OR Firebase UID)
    if (typeof parcel.receiverId === "string") {
      if (mongoose.Types.ObjectId.isValid(parcel.receiverId) && parcel.receiverId.length === 24) {
        updates.receiverId = new mongoose.Types.ObjectId(parcel.receiverId);
      } else {
        // Firebase UID or other invalid value — fall back to the test user
        console.log(`  ↩ Parcel ${parcel._id}: receiverId "${parcel.receiverId}" is not an ObjectId, resetting to test user`);
        updates.receiverId = new mongoose.Types.ObjectId(FALLBACK_USER_OID);
      }
    }

    if (Object.keys(updates).length > 0) {
      await parcels.updateOne({ _id: parcel._id }, { $set: updates });
      console.log(`  ✅ Fixed parcel ${parcel._id}:`, Object.keys(updates).join(", "));
      fixed++;
    }
  }

  console.log(`\nDone. ${fixed} parcel(s) updated.`);
  process.exit(0);
}

run().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});
