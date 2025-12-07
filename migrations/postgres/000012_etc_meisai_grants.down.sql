-- Migration: etc_meisai_grants (ROLLBACK)
-- Database: PostgreSQL

REVOKE SELECT, INSERT, UPDATE, DELETE ON public.etc_meisai FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.etc_meisai FROM "747065218280-compute@developer";
REVOKE USAGE, SELECT ON SEQUENCE public.etc_meisai_id_seq FROM cloudsqliamuser;
REVOKE USAGE, SELECT ON SEQUENCE public.etc_meisai_id_seq FROM "747065218280-compute@developer";
