/* ============================================================
   CONFIGURACIÓN DE SUPABASE
   ------------------------------------------------------------
   Pega aquí los datos de tu proyecto. Los encuentras en:
   Supabase > Project Settings > API

   La "anon key" es pública por diseño: cualquiera puede verla en
   el código de la página. Eso es normal y seguro SIEMPRE que las
   políticas RLS de supabase.sql estén aplicadas.

   NUNCA pongas aquí la "service_role key": esa salta el RLS y
   daría acceso total a tus datos.
   ============================================================ */
window.SUPABASE_CONFIG = {
  url: "https://TU-PROYECTO.supabase.co",
  anonKey: "TU_ANON_KEY"
};
