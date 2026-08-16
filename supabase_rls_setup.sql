-- ════════════════════════════════════════════════════════════
-- Blocco di sicurezza per la tabella ewallet_data
-- Incolla ed esegui questo per intero nell'editor SQL di Supabase
-- (Supabase → il tuo progetto → SQL Editor → New query)
-- ════════════════════════════════════════════════════════════

-- 1) Attiva la sicurezza a livello di riga sulla tabella
--    (se è già attiva, questo comando non fa danni, la lascia com'è)
ALTER TABLE ewallet_data ENABLE ROW LEVEL SECURITY;

-- 2) Rimuove eventuali regole vecchie con lo stesso nome, per evitare conflitti
--    se questo script viene eseguito più di una volta
DROP POLICY IF EXISTS "solo_dati_propri_lettura" ON ewallet_data;
DROP POLICY IF EXISTS "solo_dati_propri_scrittura" ON ewallet_data;
DROP POLICY IF EXISTS "solo_dati_propri_modifica" ON ewallet_data;

-- 3) Un utente può LEGGERE solo la riga con il proprio user_id
CREATE POLICY "solo_dati_propri_lettura" ON ewallet_data
  FOR SELECT
  USING (auth.uid() = user_id);

-- 4) Un utente può CREARE solo righe con il proprio user_id
--    (impedisce di scrivere dati intestati a un altro account)
CREATE POLICY "solo_dati_propri_scrittura" ON ewallet_data
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 5) Un utente può MODIFICARE solo la propria riga
CREATE POLICY "solo_dati_propri_modifica" ON ewallet_data
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ════════════════════════════════════════════════════════════
-- Dopo averlo eseguito, verifica: Supabase → Table Editor →
-- ewallet_data → in alto dovrebbe comparire "RLS enabled".
-- ════════════════════════════════════════════════════════════
