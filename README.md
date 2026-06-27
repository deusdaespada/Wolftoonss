# 🐺 Wolftoon

Plataforma de leitura de mangá, manhwa e manhua — construída com React, TypeScript, Supabase e Vite.

## 🚀 Stack

- **Frontend:** React 18 + TypeScript + Vite
- **Backend/DB:** Supabase (PostgreSQL + Auth + Storage)
- **Deploy:** Vercel
- **Código:** GitHub

---

## ⚙️ Configuração do Projeto

### 1. Clone e instale

```bash
git clone https://github.com/seu-usuario/wolftoon.git
cd wolftoon
npm install
```

### 2. Configure o Supabase

1. Acesse [supabase.com](https://supabase.com) e crie um novo projeto
2. No painel, vá em **SQL Editor** e execute todo o conteúdo de `supabase-schema.sql`
3. Vá em **Settings → API** e copie a **URL** e a **anon key**

### 3. Variáveis de ambiente

Crie um arquivo `.env.local` na raiz:

```env
VITE_SUPABASE_URL=https://seu-projeto.supabase.co
VITE_SUPABASE_ANON_KEY=sua-chave-anonima-aqui
```

### 4. Configure OAuth (Login Social)

No painel do Supabase, vá em **Authentication → Providers**:

#### Google
1. Crie um projeto em [console.cloud.google.com](https://console.cloud.google.com)
2. Ative a API "Google+ API" ou "OAuth 2.0"
3. Em Credenciais, crie um **OAuth 2.0 Client ID**
4. Adicione como URI autorizado: `https://seu-projeto.supabase.co/auth/v1/callback`
5. Cole o Client ID e Secret no Supabase

#### Discord
1. Acesse [discord.com/developers](https://discord.com/developers/applications)
2. Crie uma nova aplicação
3. Em OAuth2, adicione o redirect: `https://seu-projeto.supabase.co/auth/v1/callback`
4. Cole o Client ID e Secret no Supabase

#### GitHub
1. Acesse [github.com/settings/developers](https://github.com/settings/developers)
2. Crie um novo **OAuth App**
3. Homepage URL: `https://seu-site.vercel.app`
4. Callback URL: `https://seu-projeto.supabase.co/auth/v1/callback`
5. Cole o Client ID e Secret no Supabase

### 5. Configure o Storage

No painel do Supabase, vá em **Storage** e crie os buckets:

| Bucket | Acesso |
|--------|--------|
| `manga-covers` | Público |
| `manga-pages` | Público |
| `avatars` | Público |
| `banners` | Público |

Para cada bucket, vá em **Policies** e adicione uma policy de leitura pública:
```sql
-- Policy: Leitura pública
(bucket_id = 'manga-covers')
```

### 6. Rode localmente

```bash
npm run dev
```

Acesse [http://localhost:5173](http://localhost:5173)

---

## 🌐 Deploy no Vercel

### Via GitHub (recomendado)

1. Faça push do projeto para o GitHub
2. Acesse [vercel.com](https://vercel.com) e importe o repositório
3. Em **Environment Variables**, adicione:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
4. Clique em **Deploy**

### Via CLI

```bash
npm install -g vercel
vercel --prod
```

---

## 📁 Estrutura do Projeto

```
wolftoon/
├── src/
│   ├── components/
│   │   └── layout/
│   │       ├── Navbar.tsx       # Barra de navegação
│   │       ├── Footer.tsx       # Rodapé
│   │       └── MobileNav.tsx    # Nav mobile inferior
│   ├── contexts/
│   │   └── AuthContext.tsx      # Contexto de autenticação
│   ├── lib/
│   │   └── supabase.ts          # Cliente Supabase + tipos
│   ├── pages/
│   │   ├── HomePage.tsx         # Página inicial com hero + seções
│   │   ├── SeriesPage.tsx       # Catálogo com filtros
│   │   ├── MangaDetailPage.tsx  # Detalhes da série + lista de caps
│   │   ├── ReaderPage.tsx       # Leitor (webtoon + paginado)
│   │   ├── NovelsPage.tsx       # Light novels
│   │   ├── LatestPage.tsx       # Atualizações recentes
│   │   ├── ShopPage.tsx         # Loja de moedas
│   │   ├── ChatPage.tsx         # Chat em tempo real
│   │   ├── CommunityPage.tsx    # Comunidade / posts
│   │   ├── ProfilePage.tsx      # Perfil + configurações completas
│   │   └── AuthPage.tsx         # Login / Cadastro + OAuth
│   ├── App.tsx                  # Roteamento principal
│   ├── main.tsx                 # Entry point
│   └── index.css                # Estilos globais (design system)
├── supabase-schema.sql          # Schema completo do banco
├── vercel.json                  # Config Vercel (SPA routing)
├── .env.example                 # Exemplo de variáveis
└── vite.config.ts
```

---

## 🎨 Páginas Implementadas

| Rota | Página |
|------|--------|
| `/` | Home com hero slider, séries em alta, atualizações |
| `/series` | Catálogo com busca, filtros por tipo, gênero e status |
| `/manga/:slug` | Detalhes, lista de capítulos, comentários |
| `/manga/:slug/chapter/:n` | Leitor (webtoon/paginado) |
| `/novels` | Lista de light novels |
| `/latest` | Atualizações agrupadas por dia |
| `/shop` | Pacotes de moedas + FAQ |
| `/chat` | Chat em tempo real por grupos |
| `/community` | Posts e discussões |
| `/profile` | Perfil, favoritos, histórico, configurações |
| `/login` | Login com email + Google/Discord/GitHub |
| `/register` | Cadastro com email + Google/Discord/GitHub |

---

## 🗄️ Banco de Dados

Tabelas principais:
- `profiles` — perfis de usuário
- `manga` — séries de mangá/manhwa/manhua
- `chapters` — capítulos de cada série
- `chapter_pages` — páginas de cada capítulo
- `bookmarks` — favoritos dos usuários
- `reading_history` — histórico de leitura
- `purchased_chapters` — capítulos desbloqueados
- `comments` — comentários e respostas
- `coin_packages` — pacotes de moedas

---

## 🔐 Autenticação

- Email + senha (com validação)
- Google OAuth
- Discord OAuth  
- GitHub OAuth
- Auto-criação de perfil via trigger no Supabase

---

## 📱 Responsivo

- Desktop: navegação completa com barra lateral
- Mobile: navegação inferior fixa (iOS/Android style)
- Leitor adaptável ao tamanho da tela

---

## 🛠️ Próximos Passos

- [ ] Integração de pagamento (Stripe/Mercado Pago) para moedas
- [ ] Upload de capítulos via painel admin
- [ ] Notificações em tempo real (Supabase Realtime)
- [ ] PWA / instalação no celular
- [ ] Sistema de ranking e conquistas
- [ ] Chat em tempo real (Supabase Realtime)
