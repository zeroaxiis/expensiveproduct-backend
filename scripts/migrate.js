import 'dotenv/config';
import { migrate } from 'drizzle-orm/node-postgres/migrator';
import db from '../config/db.js';

async function runMigrations() {
  try {
    // Validate DB_URI is loaded
    if (!process.env.DB_URI) {
      throw new Error('DB_URI environment variable is not set. Please check your .env file.');
    }
    
    console.log(' Running migrations...');
    await migrate(db, { migrationsFolder: './drizzle' });
    console.log(' Migrations completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error(' Migration error:', error.message);
    if (error.cause) {
      console.error('Cause:', error.cause.message);
    }
    process.exit(1);
  }
}

runMigrations();