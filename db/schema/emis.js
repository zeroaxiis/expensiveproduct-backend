import { pgTable, uuid, varchar, decimal, date, integer, timestamp } from 'drizzle-orm/pg-core';
import { users } from './users.js';
import { categories } from './categories.js';

export const emis = pgTable('emis', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  title: varchar('title', { length: 255 }).notNull(),
  totalAmount: decimal('total_amount', { precision: 15, scale: 2 }).notNull(),
  monthlyInstallment: decimal('monthly_installment', { precision: 15, scale: 2 }).notNull(),
  currency: varchar('currency', { length: 10 }).notNull(),
  startDate: date('start_date').notNull(),
  numberOfInstallments: integer('number_of_installments').notNull(),
  remainingInstallments: integer('remaining_installments').notNull(),
  categoryId: uuid('category_id').references(() => categories.id, { onDelete: 'set null' }),
  status: varchar('status', { length: 20 }).default('active'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  deletedAt: timestamp('deleted_at', { withTimezone: true }),
});

