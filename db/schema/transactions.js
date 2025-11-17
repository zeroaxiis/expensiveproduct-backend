import { pgTable, uuid, varchar, decimal, date, boolean, text, timestamp } from 'drizzle-orm/pg-core';
import { users } from './users.js';
import { categories } from './categories.js';
import { goals } from './goals.js';
import { groups } from './groups.js';

export const transactions = pgTable('transactions', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  type: varchar('type', { length: 20 }).notNull(),
  amount: decimal('amount', { precision: 15, scale: 2 }).notNull(),
  currency: varchar('currency', { length: 10 }).notNull(),
  date: date('date').notNull(),
  categoryId: uuid('category_id').references(() => categories.id, { onDelete: 'set null' }),
  description: text('description'),
  goalId: uuid('goal_id').references(() => goals.id, { onDelete: 'set null' }),
  isGroupRelated: boolean('is_group_related').default(false),
  groupId: uuid('group_id').references(() => groups.id, { onDelete: 'set null' }),
  isSettlement: boolean('is_settlement').default(false),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp('deleted_at', { withTimezone: true }),
});

