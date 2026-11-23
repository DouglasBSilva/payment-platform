-- +goose Up

GRANT SELECT, INSERT ON transactions TO ledgers_app;
GRANT SELECT, INSERT ON ledgers TO ledgers_app;
GRANT SELECT, INSERT ON accounts TO ledgers_app;
GRANT UPDATE(balance, frozen) ON accounts TO ledgers_app;

-- +goose Down
REVOKE SELECT, INSERT ON transactions FROM ledgers_app;
REVOKE SELECT, INSERT ON ledgers FROM ledgers_app;
REVOKE SELECT, INSERT, UPDATE ON accounts FROM ledgers_app;
