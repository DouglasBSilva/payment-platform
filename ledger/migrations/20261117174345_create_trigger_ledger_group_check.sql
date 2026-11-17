-- +goose Up

-- +goose StatementBegin
CREATE OR REPLACE FUNCTION check_ledger_group_creation()
    RETURNS TRIGGER
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_count      INT;
    v_sum        BIGINT;
    v_currencies INT;
BEGIN
    SELECT COUNT(*),
           COALESCE(SUM(l.amount), 0),
           COUNT(DISTINCT a.currency_iso)
    INTO v_count, v_sum, v_currencies
    FROM ledgers l
    JOIN accounts a ON a.id = l.account_id
    WHERE l.transaction_id = NEW.transaction_id
      AND l.ledger_key = NEW.ledger_key;

    IF v_count <> 2 THEN
        RAISE EXCEPTION 'pair (transaction %, key %) has % entries, expected 2',
            NEW.transaction_id, NEW.ledger_key, v_count
            USING ERRCODE = 'check_violation';
    END IF;

    IF v_sum <> 0 THEN
        RAISE EXCEPTION 'pair (transaction %, key %) sums to %, expected 0',
            NEW.transaction_id, NEW.ledger_key, v_sum
            USING ERRCODE = 'check_violation';
    END IF;

    IF v_currencies <> 1 THEN
        RAISE EXCEPTION 'pair (transaction %, key %) mixes % currencies',
            NEW.transaction_id, NEW.ledger_key, v_currencies
            USING ERRCODE = 'check_violation';
    END IF;

    RETURN NULL;
END;
$$;
-- +goose StatementEnd

CREATE CONSTRAINT TRIGGER ledger_group_check
    AFTER INSERT ON ledgers
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE FUNCTION check_ledger_group_creation();


-- +goose Down
DROP TRIGGER IF EXISTS ledger_group_check ON ledgers;
DROP FUNCTION IF EXISTS check_ledger_group_creation();
