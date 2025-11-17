import { pgTable, uuid, varchar, boolean, timestamp, uniqueIndex } from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';
import { users } from './users.js';

export const categories = pgTable('categories', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').references(() => users.id, { onDelete: 'cascade' }),
  name: varchar('name', { length: 255 }).notNull(),
  type: varchar('type', { length: 20 }).notNull(),
  isDefault: boolean('is_default').default(false),
  isArchived: boolean('is_archived').default(false),
  icon: varchar('icon', { length: 100 }),
  color: varchar('color', { length: 20 }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
}, (table) => ({
  userCategoryUnique: uniqueIndex('user_category_unique').on(table.userId, table.name),
  systemCategoryUnique: uniqueIndex('unique_system_category_name')
    .on(table.name)
    .where(sql`${table.userId} IS NULL`),
}));

