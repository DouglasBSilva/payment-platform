-- +goose Up
-- +goose StatementBegin

CREATE OR REPLACE FUNCTION block_action()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION '% is not allowed on table %', TG_OP, TG_TABLE_NAME
        USING ERRCODE = '42501';
END;
$$;

CREATE TRIGGER blocks_transactions_update_and_delete
BEFORE DELETE OR UPDATE
ON transactions
FOR EACH ROW
EXECUTE FUNCTION block_action();

CREATE TRIGGER blocks_ledgers_update_and_delete
BEFORE DELETE OR UPDATE
ON ledgers
FOR EACH ROW
EXECUTE FUNCTION block_action();

CREATE TRIGGER blocks_transactions_truncate
BEFORE TRUNCATE
ON transactions
FOR EACH STATEMENT
EXECUTE FUNCTION block_action();

CREATE TRIGGER blocks_ledgers_truncate
BEFORE TRUNCATE
ON ledgers
FOR EACH STATEMENT
EXECUTE FUNCTION block_action();

-- +goose StatementEnd



-- +goose Down
DROP TRIGGER IF EXISTS blocks_transactions_update_and_delete on transactions;
DROP TRIGGER IF EXISTS blocks_ledgers_update_and_delete on ledgers;
DROP TRIGGER IF EXISTS blocks_transactions_truncate on transactions;
DROP TRIGGER IF EXISTS blocks_ledgers_truncate on ledgers;
DROP FUNCTION IF EXISTS block_action();
