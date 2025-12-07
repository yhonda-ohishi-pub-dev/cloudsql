-- Migration: invitations_grants
-- Database: PostgreSQL
-- Description: invitationsテーブルへの権限付与

GRANT SELECT, INSERT, UPDATE, DELETE ON public.invitations TO cloudsqliamuser;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.invitations TO "747065218280-compute@developer";
