-- ============================================================
--  Invitación Bek Jan · Esquema de confirmaciones para Supabase
--  Ejecuta este archivo completo en: Supabase > SQL Editor
-- ============================================================

-- ------------------------------------------------------------
-- 1. Tabla de confirmaciones
-- ------------------------------------------------------------
create table if not exists public.confirmaciones (
  id        uuid primary key default gen_random_uuid(),
  nombre    text        not null,
  asistira  boolean     not null,
  personas  smallint    not null default 1,
  mensaje   text,
  creado_en timestamptz not null default now(),

  -- Validaciones en la base de datos, no solo en el navegador
  constraint nombre_valido   check (char_length(trim(nombre)) between 2 and 80),
  constraint personas_valido check (personas between 1 and 15),
  constraint mensaje_valido  check (mensaje is null or char_length(mensaje) <= 300)
);

create index if not exists confirmaciones_creado_en_idx
  on public.confirmaciones (creado_en desc);


-- ------------------------------------------------------------
-- 2. Row Level Security
--
--    IMPORTANTE: la anon key es pública y va visible en el HTML.
--    Estas políticas son lo único que protege los datos.
-- ------------------------------------------------------------
alter table public.confirmaciones enable row level security;

-- Los invitados (rol anon) SOLO pueden insertar su confirmación.
-- No se les da SELECT: así nadie puede leer la lista de quién viene
-- ni los mensajes de las demás familias abriendo la consola.
drop policy if exists "invitados pueden confirmar" on public.confirmaciones;
create policy "invitados pueden confirmar"
  on public.confirmaciones
  for insert
  to anon
  with check (true);

-- Solo tu cuenta de administrador puede leer y borrar.
-- CAMBIA el correo por el tuyo en las dos políticas de abajo.
drop policy if exists "admin lee confirmaciones" on public.confirmaciones;
create policy "admin lee confirmaciones"
  on public.confirmaciones
  for select
  to authenticated
  using ( (auth.jwt() ->> 'email') = 'CAMBIA_ESTO@ejemplo.com' );

drop policy if exists "admin borra confirmaciones" on public.confirmaciones;
create policy "admin borra confirmaciones"
  on public.confirmaciones
  for delete
  to authenticated
  using ( (auth.jwt() ->> 'email') = 'CAMBIA_ESTO@ejemplo.com' );


-- ------------------------------------------------------------
-- 3. Realtime (opcional)
--    Permite que el panel se actualice solo cuando llega una
--    confirmación nueva, sin recargar la página.
-- ------------------------------------------------------------
do $$
begin
  alter publication supabase_realtime add table public.confirmaciones;
exception
  when duplicate_object then null;
end $$;


-- ------------------------------------------------------------
-- 4. Vista rápida de resumen (para consultar desde el SQL Editor)
-- ------------------------------------------------------------
create or replace view public.resumen_confirmaciones as
select
  count(*)                                          as respuestas,
  count(*) filter (where asistira)                  as familias_confirmadas,
  coalesce(sum(personas) filter (where asistira),0) as total_personas,
  count(*) filter (where not asistira)              as no_podran_asistir
from public.confirmaciones;
