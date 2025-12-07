-- Migration: etc_meisai_grants
-- Database: PostgreSQL
-- Description: etc_meisaiテーブルへの権限付与

GRANT SELECT, INSERT, UPDATE, DELETE ON public.etc_meisai TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.etc_meisai TO "747065218280-compute@developer";
GRANT USAGE, SELECT ON SEQUENCE public.etc_meisai_id_seq TO cloudsqliamuser;
GRANT USAGE, SELECT ON SEQUENCE public.etc_meisai_id_seq TO "747065218280-compute@developer";
