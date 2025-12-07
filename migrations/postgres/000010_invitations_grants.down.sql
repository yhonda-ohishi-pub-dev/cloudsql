-- Migration: invitations_grants (ROLLBACK)
-- Database: PostgreSQL

REVOKE SELECT, INSERT, UPDATE, DELETE ON public.invitations FROM cloudsqliamuser;
REVOKE SELECT, INSERT, UPDATE, DELETE ON public.invitations FROM "747065218280-compute@developer";
