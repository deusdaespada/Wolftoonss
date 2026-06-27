-- Wolftoon Database Schema
-- Execute este SQL no Supabase SQL Editor

-- =====================
-- PROFILES
-- =====================
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade primary key,
  username text unique not null,
  display_name text,
  avatar_url text,
  banner_url text,
  bio text,
  coins integer default 0,
  twitter_url text,
  website_url text,
  created_at timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Perfis públicos são visíveis" on public.profiles for select using (true);
create policy "Usuários atualizam seu perfil" on public.profiles for update using (auth.uid() = id);
create policy "Usuários inserem seu perfil" on public.profiles for insert with check (auth.uid() = id);

-- Auto-criar perfil ao registrar
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, username, display_name, coins)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    0
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- =====================
-- MANGA
-- =====================
create table if not exists public.manga (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text unique not null,
  description text,
  cover_url text,
  banner_url text,
  status text default 'ongoing' check (status in ('ongoing', 'completed', 'hiatus')),
  type text default 'manhwa' check (type in ('manga', 'manhwa', 'manhua', 'novel')),
  genres text[] default '{}',
  author text,
  artist text,
  views integer default 0,
  rating numeric(3,2) default 0,
  rating_count integer default 0,
  is_premium boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.manga enable row level security;
create policy "Manga público visível" on public.manga for select using (true);

-- =====================
-- CHAPTERS
-- =====================
create table if not exists public.chapters (
  id uuid primary key default gen_random_uuid(),
  manga_id uuid references public.manga on delete cascade not null,
  number numeric not null,
  title text,
  is_premium boolean default false,
  coin_cost integer default 2,
  views integer default 0,
  created_at timestamptz default now(),
  unique(manga_id, number)
);

alter table public.chapters enable row level security;
create policy "Capítulos visíveis" on public.chapters for select using (true);

-- =====================
-- CHAPTER PAGES
-- =====================
create table if not exists public.chapter_pages (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid references public.chapters on delete cascade not null,
  page_number integer not null,
  image_url text not null,
  unique(chapter_id, page_number)
);

alter table public.chapter_pages enable row level security;
create policy "Páginas visíveis" on public.chapter_pages for select using (true);

-- =====================
-- BOOKMARKS
-- =====================
create table if not exists public.bookmarks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade not null,
  manga_id uuid references public.manga on delete cascade not null,
  created_at timestamptz default now(),
  unique(user_id, manga_id)
);

alter table public.bookmarks enable row level security;
create policy "Usuário vê seus favoritos" on public.bookmarks for select using (auth.uid() = user_id);
create policy "Usuário cria favoritos" on public.bookmarks for insert with check (auth.uid() = user_id);
create policy "Usuário remove favoritos" on public.bookmarks for delete using (auth.uid() = user_id);

-- =====================
-- READING HISTORY
-- =====================
create table if not exists public.reading_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade not null,
  manga_id uuid references public.manga on delete cascade not null,
  chapter_id uuid references public.chapters on delete cascade not null,
  read_at timestamptz default now(),
  unique(user_id, chapter_id)
);

alter table public.reading_history enable row level security;
create policy "Usuário vê histórico" on public.reading_history for select using (auth.uid() = user_id);
create policy "Usuário cria histórico" on public.reading_history for insert with check (auth.uid() = user_id);
create policy "Usuário atualiza histórico" on public.reading_history for update using (auth.uid() = user_id);

-- =====================
-- PURCHASED CHAPTERS
-- =====================
create table if not exists public.purchased_chapters (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade not null,
  chapter_id uuid references public.chapters on delete cascade not null,
  coins_spent integer not null,
  purchased_at timestamptz default now(),
  unique(user_id, chapter_id)
);

alter table public.purchased_chapters enable row level security;
create policy "Usuário vê compras" on public.purchased_chapters for select using (auth.uid() = user_id);
create policy "Usuário realiza compra" on public.purchased_chapters for insert with check (auth.uid() = user_id);

-- =====================
-- COMMENTS
-- =====================
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users on delete cascade not null,
  manga_id uuid references public.manga on delete cascade,
  chapter_id uuid references public.chapters on delete cascade,
  parent_id uuid references public.comments on delete cascade,
  content text not null,
  likes integer default 0,
  created_at timestamptz default now()
);

alter table public.comments enable row level security;
create policy "Comentários públicos" on public.comments for select using (true);
create policy "Usuário comenta" on public.comments for insert with check (auth.uid() = user_id);
create policy "Usuário edita comentário" on public.comments for update using (auth.uid() = user_id);
create policy "Usuário deleta comentário" on public.comments for delete using (auth.uid() = user_id);

-- =====================
-- COIN PACKAGES
-- =====================
create table if not exists public.coin_packages (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  coins integer not null,
  bonus_coins integer default 0,
  price_brl numeric(8,2) not null,
  is_featured boolean default false,
  created_at timestamptz default now()
);

alter table public.coin_packages enable row level security;
create policy "Pacotes públicos" on public.coin_packages for select using (true);

-- Inserir pacotes padrão
insert into public.coin_packages (name, coins, bonus_coins, price_brl, is_featured) values
  ('Iniciante', 100, 0, 4.90, false),
  ('Leitor', 300, 30, 12.90, false),
  ('Fã', 600, 90, 24.90, true),
  ('Colecionador', 1200, 240, 44.90, false),
  ('Épico', 3000, 750, 99.90, false),
  ('Lendário', 6000, 2000, 179.90, false)
on conflict do nothing;

-- =====================
-- STORAGE BUCKETS
-- =====================
-- Execute separadamente no painel do Supabase Storage:
-- 1. Criar bucket "manga-covers" (público)
-- 2. Criar bucket "manga-pages" (público)
-- 3. Criar bucket "avatars" (público)
-- 4. Criar bucket "banners" (público)

-- =====================
-- INDEXES
-- =====================
create index if not exists idx_manga_slug on public.manga(slug);
create index if not exists idx_manga_type on public.manga(type);
create index if not exists idx_manga_status on public.manga(status);
create index if not exists idx_manga_views on public.manga(views desc);
create index if not exists idx_chapters_manga_id on public.chapters(manga_id);
create index if not exists idx_chapters_number on public.chapters(manga_id, number);
create index if not exists idx_pages_chapter_id on public.chapter_pages(chapter_id);
create index if not exists idx_bookmarks_user on public.bookmarks(user_id);
create index if not exists idx_history_user on public.reading_history(user_id);
create index if not exists idx_comments_manga on public.comments(manga_id);
