import { pgTable, uuid, varchar, decimal, date, timestamp } from 'drizzle-orm/pg-core';
import { users } from './users.js';
import { categories } from './categories.js';

export const bills = pgTable('bills', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  title: varchar('title', { length: 255 }).notNull(),
  amount: decimal('amount', { precision: 15, scale: 2 }).notNull(),
  currency: varchar('currency', { length: 10 }).notNull(),
  dueDate: date('due_date').notNull(),
  categoryId: uuid('category_id').references(() => categories.id, { onDelete: 'set null' }),
  recurrence: varchar('recurrence', { length: 20 }).default('none'),
  status: varchar('status', { length: 20 }).default('upcoming'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp('deleted_at', { withTimezone: true }),
});

