import { pgTable, uuid, varchar, decimal, date, timestamp } from 'drizzle-orm/pg-core';
import { users } from './users.js';

export const goals = pgTable('goals', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  name: varchar('name', { length: 255 }).notNull(),
  targetAmount: decimal('target_amount', { precision: 15, scale: 2 }).notNull(),
  currency: varchar('currency', { length: 10 }).notNull(),
  savingType: varchar('saving_type', { length: 20 }).notNull(),
  savingAmountPerPeriod: decimal('saving_amount_per_period', { precision: 15, scale: 2 }).notNull(),
  startDate: date('start_date').notNull(),
  status: varchar('status', { length: 20 }).default('active'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp('deleted_at', { withTimezone: true }),
});

