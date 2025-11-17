import { pgTable, uuid, varchar, decimal, date, text, timestamp } from 'drizzle-orm/pg-core';
import { groups } from './groups.js';
import { users } from './users.js';
import { categories } from './categories.js';

export const groupExpenses = pgTable('group_expenses', {
  id: uuid('id').primaryKey().defaultRandom(),
  groupId: uuid('group_id').notNull().references(() => groups.id, { onDelete: 'cascade' }),
  paidBy: uuid('paid_by').notNull().references(() => users.id, { onDelete: 'restrict' }),
  totalAmount: decimal('total_amount', { precision: 15, scale: 2 }).notNull(),
  currency: varchar('currency', { length: 10 }).notNull(),
  date: date('date').notNull(),
  categoryId: uuid('category_id').references(() => categories.id, { onDelete: 'set null' }),
  description: text('description'),
  splitType: varchar('split_type', { length: 20 }).notNull(),
  status: varchar('status', { length: 20 }).default('pending'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp('deleted_at', { withTimezone: true }),
});

