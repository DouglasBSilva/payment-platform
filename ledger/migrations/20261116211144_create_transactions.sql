-- +goose Up
CREATE TABLE "transactions"
(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    type varchar NOT NULL,
    request_key uuid not null,
    reference BIGINT default null,
    actor_id BIGINT NOT NULL,
    actor_type varchar NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    reverses_id BIGINT default null,

    CONSTRAINT CHK_transaction_type CHECK (type in ('TRANSFER', 'PAYMENT', 'REFUND', 'REVERSAL', 'CORRECTION')),
    CONSTRAINT CHK_only_reversal_has_reverse_id CHECK ((reverses_id IS NOT NULL AND type = 'REVERSAL') OR
    (type <> 'REVERSAL' AND reverses_id IS NULL)),
    CONSTRAINT CHK_transaction_actor_type CHECK (actor_type in ('MERCHANT', 'OPERATOR', 'SYSTEM')),
    UNIQUE(request_key),
    FOREIGN KEY(reverses_id) REFERENCEs transactions(id)

);

-- +goose Down
DROP TABLE IF EXISTS transactions;
