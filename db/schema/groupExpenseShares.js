import { pgTable, uuid, decimal, timestamp, unique } from 'drizzle-orm/pg-core';
import { groupExpenses } from './groupExpenses.js';
import { users } from './users.js';

export const groupExpenseShares = pgTable('group_expense_shares', {
  id: uuid('id').primaryKey().defaultRandom(),
  groupExpenseId: uuid('group_expense_id').notNull().references(() => groupExpenses.id, { onDelete: 'cascade' }),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  shareAmount: decimal('share_amount', { precision: 15, scale: 2 }).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
}, (table) => ({
  uniqueExpenseUser: unique().on(table.groupExpenseId, table.userId),
}));

