import { pgTable, uuid, decimal, date, varchar, timestamp } from 'drizzle-orm/pg-core';
import { goals } from './goals.js';
import { users } from './users.js';

export const goalContributions = pgTable('goal_contributions', {
  id: uuid('id').primaryKey().defaultRandom(),
  goalId: uuid('goal_id').notNull().references(() => goals.id, { onDelete: 'cascade' }),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  amount: decimal('amount', { precision: 15, scale: 2 }).notNull(),
  contributionDate: date('contribution_date').notNull(),
  source: varchar('source', { length: 20 }).default('manual'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

