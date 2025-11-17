import 'dotenv/config';

if (!process.env.DB_URI) {
  throw new Error('DB_URI environment variable is not set. Please check your .env file.');
}

export default {
  schema: './db/schema/*.js',
  out: './drizzle',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DB_URI,
  },
};
