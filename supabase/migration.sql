-- ================================================================
-- Migration: Add tables for quiz, word_chains, app_settings
-- Apply this manually in Supabase SQL Editor
-- ================================================================

-- 0) WORDS TABLE (base table for all features)
CREATE TABLE IF NOT EXISTS words (
  word_id BIGSERIAL PRIMARY KEY,
  name_en TEXT NOT NULL,
  name_tr TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE words ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Everyone can read words" ON words;
CREATE POLICY "Everyone can read words"
  ON words FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can insert words" ON words;
CREATE POLICY "Authenticated users can insert words"
  ON words FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated users can update words" ON words;
CREATE POLICY "Authenticated users can update words"
  ON words FOR UPDATE
  USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated users can delete words" ON words;
CREATE POLICY "Authenticated users can delete words"
  ON words FOR DELETE
  USING (auth.role() = 'authenticated');

-- 0b) WORD SAMPLES TABLE
CREATE TABLE IF NOT EXISTS word_samples (
  word_sample_id BIGSERIAL PRIMARY KEY,
  word_id INT NOT NULL REFERENCES words(word_id) ON DELETE CASCADE,
  sample TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE word_samples ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Everyone can read word samples" ON word_samples;
CREATE POLICY "Everyone can read word samples"
  ON word_samples FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can insert word samples" ON word_samples;
CREATE POLICY "Authenticated users can insert word samples"
  ON word_samples FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Authenticated users can delete word samples" ON word_samples;
CREATE POLICY "Authenticated users can delete word samples"
  ON word_samples FOR DELETE
  USING (auth.role() = 'authenticated');

-- 1) QUIZ PROGRESS TABLE (Story 3 — core spaced repetition)
CREATE TABLE IF NOT EXISTS quiz_progress (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  word_id INT NOT NULL REFERENCES words(word_id) ON DELETE CASCADE,
  consecutive_correct INT NOT NULL DEFAULT 0,
  review_level INT NOT NULL DEFAULT 0,
  next_review_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_answered_at TIMESTAMPTZ,
  is_mastered BOOLEAN NOT NULL DEFAULT FALSE,
  total_attempts INT NOT NULL DEFAULT 0,
  total_correct INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, word_id)
);

CREATE INDEX IF NOT EXISTS idx_quiz_progress_user_review 
  ON quiz_progress(user_id, is_mastered, next_review_at);

ALTER TABLE quiz_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own quiz progress" ON quiz_progress;
CREATE POLICY "Users can manage own quiz progress"
  ON quiz_progress FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 2) QUIZ SESSION LOG
CREATE TABLE IF NOT EXISTS quiz_sessions (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  total_questions INT NOT NULL DEFAULT 0,
  correct_answers INT NOT NULL DEFAULT 0,
  wrong_answers INT NOT NULL DEFAULT 0,
  duration_seconds INT,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

ALTER TABLE quiz_sessions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own quiz sessions" ON quiz_sessions;
CREATE POLICY "Users can manage own quiz sessions"
  ON quiz_sessions FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 3) QUIZ SESSION DETAILS
CREATE TABLE IF NOT EXISTS quiz_answers (
  id BIGSERIAL PRIMARY KEY,
  session_id BIGINT NOT NULL REFERENCES quiz_sessions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  word_id INT NOT NULL REFERENCES words(word_id) ON DELETE CASCADE,
  selected_answer TEXT NOT NULL,
  correct_answer TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL,
  answered_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own quiz answers" ON quiz_answers;
CREATE POLICY "Users can manage own quiz answers"
  ON quiz_answers FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 4) WORD CHAINS TABLE (Story 7)
CREATE TABLE IF NOT EXISTS word_chains (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  words JSONB NOT NULL,
  story TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE word_chains ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own word chains" ON word_chains;
CREATE POLICY "Users can manage own word chains"
  ON word_chains FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 5) APP SETTINGS (ensure exists)
CREATE TABLE IF NOT EXISTS app_settings (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  daily_word_count INT NOT NULL DEFAULT 15,
  notifications_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  notification_time TEXT NOT NULL DEFAULT '09:00',
  sound_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  api_key TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own settings" ON app_settings;
CREATE POLICY "Users can manage own settings"
  ON app_settings FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
