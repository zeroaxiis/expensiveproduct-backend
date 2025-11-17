import { pgTable, uuid, varchar, text, timestamp } from 'drizzle-orm/pg-core';
import { chatSessions } from './chatSessions.js';

export const chatMessages = pgTable('chat_messages', {
  id: uuid('id').primaryKey().defaultRandom(),
  sessionId: uuid('session_id').notNull().references(() => chatSessions.id, { onDelete: 'cascade' }),
  sender: varchar('sender', { length: 20 }).notNull(),
  message: text('message').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

