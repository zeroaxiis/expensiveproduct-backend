import { pgTable, uuid, varchar, decimal, date, timestamp } from 'drizzle-orm/pg-core';
import { groups } from './groups.js';
import { users } from './users.js';
import { transactions } from './transactions.js';

export const groupSettlements = pgTable('group_settlements', {
  id: uuid('id').primaryKey().defaultRandom(),
  groupId: uuid('group_id').notNull().references(() => groups.id, { onDelete: 'cascade' }),
  fromUserId: uuid('from_user_id').notNull().references(() => users.id, { onDelete: 'restrict' }),
  toUserId: uuid('to_user_id').notNull().references(() => users.id, { onDelete: 'restrict' }),
  amount: decimal('amount', { precision: 15, scale: 2 }).notNull(),
  currency: varchar('currency', { length: 10 }).notNull(),
  settlementDate: date('settlement_date').notNull(),
  transactionId: uuid('transaction_id').references(() => transactions.id, { onDelete: 'set null' }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

