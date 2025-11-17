import { pgTable, uuid, varchar, timestamp, unique } from 'drizzle-orm/pg-core';
import { groups } from './groups.js';
import { users } from './users.js';

export const groupMembers = pgTable('group_members', {
  id: uuid('id').primaryKey().defaultRandom(),
  groupId: uuid('group_id').notNull().references(() => groups.id, { onDelete: 'cascade' }),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  role: varchar('role', { length: 20 }).default('member'),
  joinedAt: timestamp('joined_at', { withTimezone: true }).defaultNow().notNull(),
}, (table) => ({
  uniqueGroupUser: unique().on(table.groupId, table.userId),
}));

