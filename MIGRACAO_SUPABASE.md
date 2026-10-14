# Migração para o seu Supabase

1. Crie um projeto em supabase.com e preencha o `.env` (veja `.env.example`) e o `project_id` em `supabase/config.toml`.
2. `npx supabase link --project-ref SEU-PROJETO`
3. `npx supabase db push` — roda todas as migrations, incluindo `20260614000000_storage_buckets.sql` (cria os buckets `chapters` e `covers` e as policies).
4. `npx supabase functions deploy` (check-ip-block, delete-account, notify-new-chapter, notify-vip-expiration, redeem-vip-code, serve-image).
5. Se já há imagens no projeto antigo, copie os arquivos dos buckets e atualize as URLs salvas no banco:
   `UPDATE chapters SET pages = replace(pages::text, 'encmakrlmutvsdzpodov', 'SEU-PROJETO')::jsonb;`
   (ajuste a coluna/tabela conforme seu schema; cheque também `titles.cover_url` e `profiles.avatar_url/banner_url`).
6. Dê o papel admin ao seu usuário na tabela `user_roles`.
