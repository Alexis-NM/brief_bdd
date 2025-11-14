-- ====================================
--  TRIGGER DE GESTION DES TIMESTAMPS
-- ====================================

DROP TRIGGER IF EXISTS trg_timestamps_adresse ON adresse;
DROP FUNCTION IF EXISTS set_timestamps_adresse();

CREATE OR REPLACE FUNCTION set_timestamps_adresse()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF TG_OP = 'INSERT' THEN
        IF NEW.date_creation IS NULL THEN
            NEW.date_creation := now();
        END IF;
        NEW.date_mise_a_jour := NEW.date_creation;

    ELSIF TG_OP = 'UPDATE' THEN
        NEW.date_creation := OLD.date_creation;
        NEW.date_mise_a_jour := now();
    END IF;

    RETURN NEW;
END;
$$;


CREATE TRIGGER trg_timestamps_adresse
BEFORE INSERT OR UPDATE ON adresse
FOR EACH ROW
EXECUTE FUNCTION set_timestamps_adresse();