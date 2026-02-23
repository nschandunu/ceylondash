'use strict';

/**
 * CeylonDash — Database Seeder
 *
 * Usage:
 *   node scripts/seedDatabase.js
 *
 * Prerequisites:
 *   1. The test user must already be registered in the app (so a local User
 *      document with the matching firebaseUid exists in MongoDB).
 *   2. Replace TEST_USER_FIREBASE_UID below with the actual Firebase UID.
 */

const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

const mongoose = require('mongoose');
const User = require('../src/models/User');
const Parcel = require('../src/models/Parcel');

// ─────────────────────────────────────────────────────────────────────────────
// CONFIGURATION — load the real Firebase UID of your test account from .env
// ─────────────────────────────────────────────────────────────────────────────
const TEST_USER_FIREBASE_UID = process.env.TEST_USER_FIREBASE_UID;

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Find an existing user by phone number, or create a fresh one.
 * Relies on Mongoose pre-save hook to bcrypt-hash the password.
 */
async function findOrCreateUser({ name, phoneNumber }) {
  const existing = await User.findOne({ phoneNumber });
  if (existing) return existing;

  const user = new User({
    name,
    phoneNumber,
    password: 'Seed@1234!', // hashed by the pre-save hook
    role: 'user',
  });

  return user.save();
}

/**
 * Build a statusHistory array with each status separated by 6 hours,
 * starting from `startDate`.
 */
function buildHistory(statuses, startDate) {
  return statuses.map((status, i) => ({
    status,
    updatedAt: new Date(startDate.getTime() + i * 6 * 60 * 60 * 1000),
  }));
}

/** Return a Date that is `days` days before now. */
const daysAgo = (days) =>
  new Date(Date.now() - days * 24 * 60 * 60 * 1000);

// ─────────────────────────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────────────────────────
async function seedDatabase() {
  // ── 0. Pre-flight checks ──────────────────────────────────────────────────
  if (!process.env.MONGO_URI) {
    console.error('[Seeder] ERROR: MONGO_URI is not defined in .env');
    process.exit(1);
  }

  if (!TEST_USER_FIREBASE_UID || TEST_USER_FIREBASE_UID === 'REPLACE_WITH_YOUR_FIREBASE_UID') {
    console.error(
      '[Seeder] ERROR: TEST_USER_FIREBASE_UID is not defined in .env.\n' +
      '         Please add TEST_USER_FIREBASE_UID=your_firebase_uid to your .env file.'
    );
    process.exit(1);
  }

  // ── 1. Connect ────────────────────────────────────────────────────────────
  console.log('[Seeder] Connecting to MongoDB...');
  await mongoose.connect(process.env.MONGO_URI);
  console.log('[Seeder] Connected.\n');

  // ── 2. Locate the test user ───────────────────────────────────────────────
  const testUser = await User.findOne({ firebaseUid: TEST_USER_FIREBASE_UID });

  if (!testUser) {
    console.error(
      `[Seeder] ERROR: No User found with firebaseUid="${TEST_USER_FIREBASE_UID}".\n` +
        '         Please register the account in the app first, then re-run this script.',
    );
    await mongoose.disconnect();
    process.exit(1);
  }

  console.log(`[Seeder] Test user: "${testUser.name}" (${testUser._id})\n`);

  // ── 3. Ensure partner store / customer users exist ────────────────────────
  console.log('[Seeder] Creating partner users (if needed)...');

  const [hub, electronics, fashionZone, techInn, residential] =
    await Promise.all([
      findOrCreateUser({ name: 'Main Street Hub',        phoneNumber: '+94770000001' }),
      findOrCreateUser({ name: 'Island Electronics',     phoneNumber: '+94770000002' }),
      findOrCreateUser({ name: 'Kandy Fashion Zone',     phoneNumber: '+94770000003' }),
      findOrCreateUser({ name: 'Tech Innovations PVT',   phoneNumber: '+94770000004' }),
      findOrCreateUser({ name: 'Nimal Perera',           phoneNumber: '+94770000005' }),
    ]);

  console.log('  ✓ Partner users ready.\n');

  // ── 4. Clear prior seed data for this test user ───────────────────────────
  const deleted = await Parcel.deleteMany({
    $or: [{ senderId: testUser._id }, { receiverId: testUser._id }],
  });
  console.log(
    `[Seeder] Cleared ${deleted.deletedCount} existing parcel(s) for test user.\n`,
  );

  // ── 5. Build parcel documents ─────────────────────────────────────────────
  //
  //  Mix of statuses and roles so the test user appears as both
  //  sender and receiver — matching the $or filter in getAllParcels.
  //
  const parcels = [
    // ── 1 · pending — testUser is RECEIVER ─────────────────────────────────
    {
      senderId:        hub._id,
      senderName:      hub.name,
      receiverId:      testUser._id,
      trackingCode:    'CLN-SEED-001',
      deliveryAddress: '45 Galle Road, Dehiwala, Western Province',
      status:          'pending',
      statusHistory:   buildHistory(['pending'], daysAgo(1)),
      codAmount:       5500,
    },

    // ── 2 · in_transit — testUser is RECEIVER ──────────────────────────────
    {
      senderId:        electronics._id,
      senderName:      electronics.name,
      receiverId:      testUser._id,
      trackingCode:    'CLN-SEED-002',
      deliveryAddress: '12 Duplication Road, Kollupitiya, Colombo 3',
      status:          'in_transit',
      statusHistory:   buildHistory(['pending', 'in_transit'], daysAgo(3)),
      codAmount:       22500,
    },

    // ── 3 · in_transit — testUser is SENDER ────────────────────────────────
    {
      senderId:        testUser._id,
      senderName:      testUser.name,
      receiverId:      residential._id,
      trackingCode:    'CLN-SEED-003',
      deliveryAddress: '78 Temple Street, Kandy, Central Province',
      status:          'in_transit',
      statusHistory:   buildHistory(['pending', 'in_transit'], daysAgo(2)),
      codAmount:       0,
    },

    // ── 4 · out_for_delivery — testUser is RECEIVER ────────────────────────
    {
      senderId:        fashionZone._id,
      senderName:      fashionZone.name,
      receiverId:      testUser._id,
      trackingCode:    'CLN-SEED-004',
      deliveryAddress: '33 Hill Street, Matara, Southern Province',
      status:          'out_for_delivery',
      statusHistory:   buildHistory(
        ['pending', 'in_transit', 'out_for_delivery'],
        daysAgo(4),
      ),
      codAmount:       4800,
    },

    // ── 5 · delivered — testUser is RECEIVER ───────────────────────────────
    {
      senderId:        hub._id,
      senderName:      hub.name,
      receiverId:      testUser._id,
      trackingCode:    'CLN-SEED-005',
      deliveryAddress: '99 Marine Drive, Negombo, Western Province',
      status:          'delivered',
      statusHistory:   buildHistory(
        ['pending', 'in_transit', 'out_for_delivery', 'delivered'],
        daysAgo(7),
      ),
      codAmount:       12000,
    },

    // ── 6 · delivered — testUser is SENDER ─────────────────────────────────
    {
      senderId:        testUser._id,
      senderName:      testUser.name,
      receiverId:      electronics._id,
      trackingCode:    'CLN-SEED-006',
      deliveryAddress: '56 Hospital Road, Jaffna, Northern Province',
      status:          'delivered',
      statusHistory:   buildHistory(
        ['pending', 'in_transit', 'out_for_delivery', 'delivered'],
        daysAgo(10),
      ),
      codAmount:       8750,
    },

    // ── 7 · cancelled — testUser is RECEIVER ───────────────────────────────
    {
      senderId:        fashionZone._id,
      senderName:      fashionZone.name,
      receiverId:      testUser._id,
      trackingCode:    'CLN-SEED-007',
      deliveryAddress: '22 Victoria Park Road, Nuwara Eliya',
      status:          'cancelled',
      statusHistory:   buildHistory(['pending', 'cancelled'], daysAgo(6)),
      codAmount:       0,
    },

    // ── 8 · failed — testUser is RECEIVER ──────────────────────────────────
    {
      senderId:        techInn._id,
      senderName:      techInn.name,
      receiverId:      testUser._id,
      trackingCode:    'CLN-SEED-008',
      deliveryAddress: '14 Rajapihilla Mawatha, Kandy, Central Province',
      status:          'failed',
      statusHistory:   buildHistory(
        ['pending', 'in_transit', 'failed'],
        daysAgo(5),
      ),
      codAmount:       45000,
    },
  ];

  // ── 6. Insert ─────────────────────────────────────────────────────────────
  const inserted = await Parcel.insertMany(parcels);

  console.log(`[Seeder] Inserted ${inserted.length} parcel(s):`);
  inserted.forEach((p) =>
    console.log(`  ✓ ${p.trackingCode.padEnd(14)} — ${p.status}`),
  );

  // ── 7. Done ───────────────────────────────────────────────────────────────
  await mongoose.disconnect();
  console.log('\nDatabase Seeded Successfully');
}

// ─────────────────────────────────────────────────────────────────────────────
seedDatabase().catch(async (err) => {
  console.error('[Seeder] Fatal Error:', err.message);
  await mongoose.disconnect();
  process.exit(1);
});
