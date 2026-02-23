/**
 * Diagnostic script: shows which database Mongoose is connecting to,
 * what collections exist, and whether the test user is found.
 *
 * Run from the backend directory:
 *   node src/scripts/diagnose-db.js
 */

require("dotenv").config();
const mongoose = require("mongoose");

async function run() {
  await mongoose.connect(process.env.MONGO_URI);

  const db = mongoose.connection.db;
  console.log("Connected to database:", db.databaseName);

  const cols = await db.listCollections().toArray();
  console.log("Collections:", cols.map((c) => c.name));

  if (cols.find((c) => c.name === "users")) {
    const users = await db.collection("users").find({}).toArray();
    console.log(`\nUsers in '${db.databaseName}'.users (${users.length} total):`);
    users.forEach((u) =>
      console.log(`  _id: ${u._id}  firebaseUid: ${u.firebaseUid}  name: ${u.name}`)
    );
  } else {
    console.log("\n⚠️  No 'users' collection found in this database.");
  }

  // List all databases so we can see where the data actually lives
  const adminDb = db.admin();
  const { databases } = await adminDb.listDatabases();
  console.log(
    "\nAll databases on the cluster:",
    databases.map((d) => d.name)
  );

  process.exit(0);
}

run().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});
