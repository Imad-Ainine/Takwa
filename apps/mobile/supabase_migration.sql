-- ═══════════════════════════════════════════════════════════════
--  Supabase Migration: Takwa Islamic Books & Reminders
-- ═══════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────
-- 1. BOOKS TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.books (
    id TEXT PRIMARY KEY,
    title_ar TEXT NOT NULL,
    title_en TEXT NOT NULL,
    author_ar TEXT NOT NULL,
    author_en TEXT NOT NULL,
    description_ar TEXT NOT NULL,
    emoji TEXT DEFAULT '📚',
    category TEXT NOT NULL,
    cover_url TEXT,
    pdf_url TEXT,
    publish_year INTEGER,
    cover_color TEXT DEFAULT '0xFFC8A96E',
    cover_color_2 TEXT DEFAULT '0xFF3AAFA9',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.books ENABLE ROW LEVEL SECURITY;

-- Public READ access
CREATE POLICY "Allow public read access for books"
ON public.books FOR SELECT
TO public
USING (true);

-- ─────────────────────────────────────────
-- 2. BOOK READING PROGRESS TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.book_reading_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    book_id TEXT NOT NULL REFERENCES public.books(id) ON DELETE CASCADE,
    chapter_index INTEGER NOT NULL DEFAULT 0,
    page_index INTEGER NOT NULL DEFAULT 0,
    read_pages JSONB DEFAULT '[]',
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, book_id)
);

-- Enable RLS
ALTER TABLE public.book_reading_progress ENABLE ROW LEVEL SECURITY;

-- Owner-only access
CREATE POLICY "Users can manage their own book progress"
ON public.book_reading_progress FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ─────────────────────────────────────────
-- 3. REMINDERS TABLE
-- ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.reminders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    local_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    icon_name TEXT NOT NULL,
    time TEXT NOT NULL, -- Format: HH:mm
    is_enabled BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, local_id)
);

-- Enable RLS
ALTER TABLE public.reminders ENABLE ROW LEVEL SECURITY;

-- Owner-only access
CREATE POLICY "Users can manage their own reminders"
ON public.reminders FOR ALL
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- ─────────────────────────────────────────
-- 4. SEED DATA (3 BOOKS)
-- ─────────────────────────────────────────
INSERT INTO public.books (id, title_ar, title_en, author_ar, author_en, description_ar, emoji, category, cover_url, pdf_url, publish_year, cover_color, cover_color_2)
VALUES 
(
    'arboun_nawawi', 
    'الأربعون النووية', 
    'The Forty Hadith of Imam al-Nawawi', 
    'الإمام يحيى بن شرف النووي', 
    'Imam al-Nawawi', 
    'مجموعة من أهم الأحاديث النبوية الشريفة، جمعها الإمام النووي رحمه الله، وهي تمثل أسس الإسلام وأركانه، تشمل مواضيع شتى من العقيدة والعبادات والمعاملات والأخلاق.', 
    '📜', 
    'hadith', 
    'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1381021768i/6740315.jpg', 
    'https://d1.islamhouse.com/data/ar/ih_books/parts/Forty_Nawawi_Hadith/ar_Forty_Nawawi_Hadith_Dar_Alsalam.pdf', 
    631, 
    '0xFFC8A96E', 
    '0xFF3AAFA9'
),
(
    'riyad_salihin', 
    'رياض الصالحين', 
    'Gardens of the Righteous', 
    'الإمام يحيى بن شرف النووي', 
    'Imam al-Nawawi', 
    'كتاب جامع للآيات القرآنية والأحاديث النبوية الشريفة في ترقية النفوس وتزكيتها والسمو بها نحو الكمال، مرتب على أبواب من الآداب والأخلاق والعبادات.', 
    '🌿', 
    'adab', 
    'https://www.noor-book.com/publice/covers_cache_webp/3/b/6/2/277b87d65ab623e3b228d355b7322ae6.jpg.webp', 
    'https://d1.islamhouse.com/data/ar/ih_books/single_01/ar_Riyad_usSaliheen.pdf', 
    670, 
    '0xFF2E7D32', 
    '0xFFC8A96E'
),
(
    'zad_al_maad_4', 
    'زاد المعاد المجلد الرابع', 
    'Provisions for the Hereafter Vol 4', 
    'الإمام ابن قيم الجوزية', 
    'Ibn Qayyim al-Jawziyyah', 
    'كتاب نفيس في السيرة النبوية وهَدي النبي ﷺ في عباداته ومعاملاته وأحكامه، يجمع بين الفقه والسيرة في أسلوب علمي رائع.', 
    '🏹', 
    'seerah', 
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTSZge4_YviGc-FhpZ5O4YRV1t_9Nmuqw16gQ&s', 
    'https://d1.islamhouse.com/data/ar/ih_books/single-03/ar-Zaad-Almaad4.pdf', 
    751, 
    '0xFF1565C0', 
    '0xFFC8A96E'
)
ON CONFLICT (id) DO NOTHING;

-- ─────────────────────────────────────────
-- 5. PDF SESSION COLUMNS (run once)
-- ─────────────────────────────────────────
-- Adds reading timer, current pdf page, and total pdf pages
-- to the existing book_reading_progress table.
ALTER TABLE public.book_reading_progress
  ADD COLUMN IF NOT EXISTS pdf_page        INTEGER NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS total_pdf_pages  INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS reading_seconds  BIGINT  NOT NULL DEFAULT 0;
