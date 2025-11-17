import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import 'dotenv/config';
import * as schema from '../db/schema/index.js';

// Validate DB_URI is set
if (!process.env.DB_URI) {
  throw new Error('DB_URI environment variable is not set. Please check your .env file.');
}

// Create connection pool
const pool = new Pool({
  connectionString: process.env.DB_URI,
  ssl: {
    rejectUnauthorized: false // Required for Neon
  }
});

// Create Drizzle instance with schema
const db = drizzle(pool, { schema });

// Test connection
pool.on('connect', () => {
  console.log(' Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  console.error(' Unexpected error on idle client', err);
  process.exit(-1);
});

export default db;
export { pool }; // Export pool if needed for raw queries