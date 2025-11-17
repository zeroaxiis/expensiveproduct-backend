import { pgTable, uuid, varchar, decimal, timestamp, unique } from 'drizzle-orm/pg-core';

export const currencyRates = pgTable('currency_rates', {
  id: uuid('id').primaryKey().defaultRandom(),
  baseCurrency: varchar('base_currency', { length: 10 }).notNull(),
  targetCurrency: varchar('target_currency', { length: 10 }).notNull(),
  rate: decimal('rate', { precision: 20, scale: 8 }).notNull(),
  fetchedAt: timestamp('fetched_at', { withTimezone: true }).defaultNow().notNull(),
}, (table) => ({
  uniqueCurrencyRate: unique().on(table.baseCurrency, table.targetCurrency, table.fetchedAt),
}));

