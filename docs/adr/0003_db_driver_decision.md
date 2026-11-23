# Context

- Select the driver that defines how the Go app talks to Postgres. The ledger write path decides what to do from the
  Postgres error code (SQLSTATE), so the driver must expose it without wrapping:
  - `23505` unique violation on `request_key` → idempotent replay: return the existing transaction.
  - `23514` CHECK violation (e.g. balance would go negative) → reject the transfer.
  - `40001` serialization failure / `40P01` deadlock detected → retry the whole transaction.
- Locks themselves are not errors: with `FOR UPDATE` in ascending id order, a concurrent session waits for the lock.

# Decision

- pgx native interface + pgxpool.

# Gain

- Direct access to the error code: `errors.As(err, &pgErr)` gives `pgErr.Code`, with no `database/sql` layer in between.
- pgxpool is Postgres-aware (health checks, connection lifetime settings).
- Secondary: the native interface is faster and exposes Postgres-only features (COPY, LISTEN/NOTIFY), not used yet.

# Give up

- Libraries that expect `*sql.DB` will not accept a pgxpool. If one is ever needed, `pgx/stdlib` can expose a `*sql.DB`.
- It is Postgres-only, so there is no portability across databases. This is accepted: ADR 0001 already ties the ledger to
  Postgres (`TIMESTAMPTZ`, deferred triggers, SQLSTATE codes).
