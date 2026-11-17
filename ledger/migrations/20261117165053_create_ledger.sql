-- +goose Up
CREATE TABLE IF NOT EXISTS ledgers
(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    amount BIGINT NOT NULL,
    transaction_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    ledger_key INT NOT NULL,

    FOREIGN KEY(transaction_id) REFERENCES transactions(id),
    FOREIGN KEY(account_id) REFERENCES accounts(id),
    CONSTRAINT CHK_existing_amount CHECK (amount <> 0),
    UNIQUE(transaction_id, account_id, ledger_key)
);

CREATE INDEX ledgers_account_id ON ledgers(account_id, id);

-- +goose Down
DROP TABLE IF EXISTS ledgers;
