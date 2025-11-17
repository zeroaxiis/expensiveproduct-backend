
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- 1. USERS TABLE

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  default_currency VARCHAR(10) DEFAULT 'USD',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- 2. USER SETTINGS TABLE
CREATE TABLE IF NOT EXISTS user_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  language VARCHAR(10) DEFAULT 'en',
  timezone VARCHAR(50) DEFAULT 'UTC',
  notification_preferences JSONB DEFAULT '{}',
  profile_picture_url VARCHAR(500),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- 3. REFRESH TOKENS TABLE

CREATE TABLE IF NOT EXISTS refresh_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token VARCHAR(500) NOT NULL UNIQUE,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- 4. CATEGORIES TABLE

CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE, -- NULL = system default category
  name VARCHAR(255) NOT NULL,
  type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense', 'both')),
  is_default BOOLEAN DEFAULT FALSE,
  is_archived BOOLEAN DEFAULT FALSE,
  icon VARCHAR(100),
  color VARCHAR(20),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, name)
);


--  Unique system categories

CREATE UNIQUE INDEX IF NOT EXISTS unique_system_category_name
  ON categories (name)
  WHERE user_id IS NULL;


-- 5. GOALS TABLE
CREATE TABLE IF NOT EXISTS goals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  target_amount DECIMAL(15, 2) NOT NULL CHECK (target_amount > 0),
  currency VARCHAR(10) NOT NULL,
  saving_type VARCHAR(20) NOT NULL CHECK (saving_type IN ('daily', 'monthly')),
  saving_amount_per_period DECIMAL(15, 2) NOT NULL CHECK (saving_amount_per_period > 0),
  start_date DATE NOT NULL,
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);


-- 6. GROUPS TABLE 
CREATE TABLE IF NOT EXISTS groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  currency VARCHAR(10) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);


-- 7. TRANSACTIONS TABLE
CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense')),
  amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
  currency VARCHAR(10) NOT NULL,
  date DATE NOT NULL,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  description TEXT,
  goal_id UUID REFERENCES goals(id) ON DELETE SET NULL,
  is_group_related BOOLEAN DEFAULT FALSE,
  group_id UUID REFERENCES groups(id) ON DELETE SET NULL,
  is_settlement BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);


-- 8. BILLS TABLE
CREATE TABLE IF NOT EXISTS bills (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
  currency VARCHAR(10) NOT NULL,
  due_date DATE NOT NULL,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  recurrence VARCHAR(20) DEFAULT 'none' CHECK (recurrence IN ('none', 'monthly', 'yearly', 'custom')),
  status VARCHAR(20) DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'paid', 'overdue')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);


-- 9. EMIS TABLE
CREATE TABLE IF NOT EXISTS emis (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  total_amount DECIMAL(15, 2) NOT NULL CHECK (total_amount > 0),
  monthly_installment DECIMAL(15, 2) NOT NULL CHECK (monthly_installment > 0),
  currency VARCHAR(10) NOT NULL,
  start_date DATE NOT NULL,
  number_of_installments INTEGER NOT NULL CHECK (number_of_installments > 0),
  remaining_installments INTEGER NOT NULL CHECK (remaining_installments >= 0),
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);


-- 10. GOAL CONTRIBUTIONS TABLE
CREATE TABLE IF NOT EXISTS goal_contributions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
  contribution_date DATE NOT NULL,
  source VARCHAR(20) DEFAULT 'manual' CHECK (source IN ('manual', 'auto')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- 11. GROUP MEMBERS TABLE
CREATE TABLE IF NOT EXISTS group_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role VARCHAR(20) DEFAULT 'member' CHECK (role IN ('owner', 'member')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(group_id, user_id)
);


-- 12. GROUP EXPENSES TABLE
CREATE TABLE IF NOT EXISTS group_expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  paid_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  total_amount DECIMAL(15, 2) NOT NULL CHECK (total_amount > 0),
  currency VARCHAR(10) NOT NULL,
  date DATE NOT NULL,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  description TEXT,
  split_type VARCHAR(20) NOT NULL CHECK (split_type IN ('equal', 'percentage', 'share', 'custom')),
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP WITH TIME ZONE NULL
);


-- 13. GROUP EXPENSE SHARES TABLE
CREATE TABLE IF NOT EXISTS group_expense_shares (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_expense_id UUID NOT NULL REFERENCES group_expenses(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  share_amount DECIMAL(15, 2) NOT NULL CHECK (share_amount >= 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(group_expense_id, user_id)
);


-- 14. GROUP SETTLEMENTS TABLE
CREATE TABLE IF NOT EXISTS group_settlements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  from_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  to_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
  currency VARCHAR(10) NOT NULL,
  settlement_date DATE NOT NULL,
  transaction_id UUID REFERENCES transactions(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- 15. CURRENCY RATES TABLE
CREATE TABLE IF NOT EXISTS currency_rates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  base_currency VARCHAR(10) NOT NULL,
  target_currency VARCHAR(10) NOT NULL,
  rate DECIMAL(20, 8) NOT NULL CHECK (rate > 0),
  fetched_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(base_currency, target_currency, fetched_at)
);


-- 16. CHAT SESSIONS TABLE (for AI Assistant)
CREATE TABLE IF NOT EXISTS chat_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- 17. CHAT MESSAGES TABLE
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
  sender VARCHAR(20) NOT NULL CHECK (sender IN ('user', 'assistant')),
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- User settings indexes
CREATE INDEX IF NOT EXISTS idx_user_settings_user_id ON user_settings(user_id);

-- Refresh tokens indexes
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);

-- Categories indexes
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON categories(user_id);
CREATE INDEX IF NOT EXISTS idx_categories_type ON categories(type);
CREATE INDEX IF NOT EXISTS idx_categories_is_default ON categories(is_default);

-- Transactions indexes
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(date);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_category_id ON transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_goal_id ON transactions(goal_id);
CREATE INDEX IF NOT EXISTS idx_transactions_group_id ON transactions(group_id);
CREATE INDEX IF NOT EXISTS idx_transactions_deleted_at ON transactions(deleted_at) WHERE deleted_at IS NULL;

-- Bills indexes
CREATE INDEX IF NOT EXISTS idx_bills_user_id ON bills(user_id);
CREATE INDEX IF NOT EXISTS idx_bills_due_date ON bills(due_date);
CREATE INDEX IF NOT EXISTS idx_bills_status ON bills(status);
CREATE INDEX IF NOT EXISTS idx_bills_deleted_at ON bills(deleted_at) WHERE deleted_at IS NULL;

-- EMIs indexes
CREATE INDEX IF NOT EXISTS idx_emis_user_id ON emis(user_id);
CREATE INDEX IF NOT EXISTS idx_emis_start_date ON emis(start_date);
CREATE INDEX IF NOT EXISTS idx_emis_status ON emis(status);
CREATE INDEX IF NOT EXISTS idx_emis_deleted_at ON emis(deleted_at) WHERE deleted_at IS NULL;

-- Goals indexes
CREATE INDEX IF NOT EXISTS idx_goals_user_id ON goals(user_id);
CREATE INDEX IF NOT EXISTS idx_goals_status ON goals(status);
CREATE INDEX IF NOT EXISTS idx_goals_deleted_at ON goals(deleted_at) WHERE deleted_at IS NULL;

-- Goal contributions indexes
CREATE INDEX IF NOT EXISTS idx_goal_contributions_goal_id ON goal_contributions(goal_id);
CREATE INDEX IF NOT EXISTS idx_goal_contributions_user_id ON goal_contributions(user_id);
CREATE INDEX IF NOT EXISTS idx_goal_contributions_contribution_date ON goal_contributions(contribution_date);

-- Groups indexes
CREATE INDEX IF NOT EXISTS idx_groups_created_by ON groups(created_by);
CREATE INDEX IF NOT EXISTS idx_groups_deleted_at ON groups(deleted_at) WHERE deleted_at IS NULL;

-- Group members indexes
CREATE INDEX IF NOT EXISTS idx_group_members_group_id ON group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_group_members_user_id ON group_members(user_id);

-- Group expenses indexes
CREATE INDEX IF NOT EXISTS idx_group_expenses_group_id ON group_expenses(group_id);
CREATE INDEX IF NOT EXISTS idx_group_expenses_paid_by ON group_expenses(paid_by);
CREATE INDEX IF NOT EXISTS idx_group_expenses_date ON group_expenses(date);
CREATE INDEX IF NOT EXISTS idx_group_expenses_deleted_at ON group_expenses(deleted_at) WHERE deleted_at IS NULL;

-- Group expense shares indexes
CREATE INDEX IF NOT EXISTS idx_group_expense_shares_expense_id ON group_expense_shares(group_expense_id);
CREATE INDEX IF NOT EXISTS idx_group_expense_shares_user_id ON group_expense_shares(user_id);

-- Group settlements indexes
CREATE INDEX IF NOT EXISTS idx_group_settlements_group_id ON group_settlements(group_id);
CREATE INDEX IF NOT EXISTS idx_group_settlements_from_user ON group_settlements(from_user_id);
CREATE INDEX IF NOT EXISTS idx_group_settlements_to_user ON group_settlements(to_user_id);
CREATE INDEX IF NOT EXISTS idx_group_settlements_settlement_date ON group_settlements(settlement_date);

-- Currency rates indexes
CREATE INDEX IF NOT EXISTS idx_currency_rates_base_target ON currency_rates(base_currency, target_currency);
CREATE INDEX IF NOT EXISTS idx_currency_rates_fetched_at ON currency_rates(fetched_at);

-- Chat sessions indexes
CREATE INDEX IF NOT EXISTS idx_chat_sessions_user_id ON chat_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_sessions_created_at ON chat_sessions(created_at);

-- Chat messages indexes
CREATE INDEX IF NOT EXISTS idx_chat_messages_session_id ON chat_messages(session_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at);


-- INSERT DEFAULT SYSTEM CATEGORIES
INSERT INTO categories (id, user_id, name, type, is_default, is_archived) VALUES
  (uuid_generate_v4(), NULL, 'Food', 'expense', TRUE, FALSE),
  (uuid_generate_v4(), NULL, 'Rent', 'expense', TRUE, FALSE),
  (uuid_generate_v4(), NULL, 'Utilities', 'expense', TRUE, FALSE),
  (uuid_generate_v4(), NULL, 'Transport', 'expense', TRUE, FALSE),
  (uuid_generate_v4(), NULL, 'Entertainment', 'expense', TRUE, FALSE),
  (uuid_generate_v4(), NULL, 'Shopping', 'expense', TRUE, FALSE),
  (uuid_generate_v4(), NULL, 'Healthcare', 'expense', TRUE, FALSE),
  (uuid_generate_v4(), NULL, 'Education', 'expense', TRUE, FALSE),
  (uuid_generate_v4(), NULL, 'Salary', 'income', TRUE, FALSE),
  (uuid_generate_v4(), NULL, 'Freelance', 'income', TRUE, FALSE),
  (uuid_generate_v4(), NULL, 'Investment', 'income', TRUE, FALSE),
  (uuid_generate_v4(), NULL, 'Other Income', 'income', TRUE, FALSE),
  (uuid_generate_v4(), NULL, 'Other Expense', 'expense', TRUE, FALSE)
ON CONFLICT DO NOTHING;


-- CREATE FUNCTION TO UPDATE updated_at TIMESTAMP
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';


-- CREATE TRIGGERS FOR updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_settings_updated_at BEFORE UPDATE ON user_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bills_updated_at BEFORE UPDATE ON bills
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_emis_updated_at BEFORE UPDATE ON emis
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_goals_updated_at BEFORE UPDATE ON goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_groups_updated_at BEFORE UPDATE ON groups
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_group_expenses_updated_at BEFORE UPDATE ON group_expenses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_chat_sessions_updated_at BEFORE UPDATE ON chat_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();