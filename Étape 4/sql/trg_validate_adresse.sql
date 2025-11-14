-- ========================
--  TRIGGER DE VALIDATION
-- ========================

DROP TRIGGER IF EXISTS trg_validate_adresse ON adresse;
DROP FUNCTION IF EXISTS validate_adresse();

CREATE OR REPLACE FUNCTION validate_adresse()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_code_postal CHAR(5);
BEGIN

    IF NEW.code_insee IS NULL THEN
        RAISE EXCEPTION 'code_insee manquant dans l’adresse (id=%)', NEW.id;
    END IF;

    SELECT code_postal
    INTO v_code_postal
    FROM commune
    WHERE code_insee = NEW.code_insee;

    IF v_code_postal IS NULL THEN
        RAISE EXCEPTION 'Aucun code postal trouvé pour la commune %', NEW.code_insee;
    END IF;

    IF v_code_postal !~ '^[0-9]{5}$' THEN
        RAISE EXCEPTION
            'Code postal invalide (%) pour la commune % (format attendu : 5 chiffres)',
            v_code_postal, NEW.code_insee;
    END IF;

    IF NEW.lat IS NOT NULL THEN
        IF NEW.lat < -90 OR NEW.lat > 90 THEN
            RAISE EXCEPTION
                'Latitude invalide (%) pour l’adresse id=% (attendu entre -90 et 90)',
                NEW.lat, NEW.id;
        END IF;
    END IF;

    IF NEW.lon IS NOT NULL THEN
        IF NEW.lon < -180 OR NEW.lon > 180 THEN
            RAISE EXCEPTION
                'Longitude invalide (%) pour l’adresse id=% (attendu entre -180 et 180)',
                NEW.lon, NEW.id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validate_adresse
BEFORE INSERT OR UPDATE ON adresse
FOR EACH ROW
EXECUTE FUNCTION validate_adresse();