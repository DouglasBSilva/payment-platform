-- +goose Up
CREATE TABLE "accounts"
(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    balance BIGINT not null default 0,
    owner_id BIGINT not null,
    type varchar not null,
    frozen BOOLEAN not null default true,
    currency_iso varchar(3) not null,
    code varchar not null,
    CONSTRAINT CHK_type CHECK (type in ('MERCHANT', 'SYSTEM')),
    CONSTRAINT CHK_Balance CHECK (balance >= 0 OR type = 'SYSTEM'),
    CONSTRAINT UQ_Accounts UNIQUE (owner_id, currency_iso, code),
    CONSTRAINT CHK_merchant_code CHECK (code = 'MAIN' OR type <> 'MERCHANT'),
    CONSTRAINT CHK_code CHECK (code in ('CLEARING', 'CORRECTIONS', 'FEES', 'MAIN'))
);

-- +goose Down
DROP TABLE IF EXISTS "accounts";
