## Context
- The model should be able to track all the movimentation that happen in any account, it should be able to track, audit and identify errors in movimentations so that i can prevent before storing any of them.

## Decision

- 3 tables will be created to achieve it.
    - 1 - accounts table where we will store the balance, type, frozen and currency
    - 2 - transaction table: one row per business event that moves money. Columns that describe the whole event, stored once:
        - `type`: what kind of event it is (transfer, payment capture, refund, reversal, correction)
        - `request_key`: the client's retry key; unique, so a retried request can't create a second transaction
        - `reference`: what caused it, e.g. the payment or refund id
        - `actor`: who or what requested it
        - `created_at`: when it happened
        - `reverses_id`: for a reversal, the transaction it undoes; the original is never edited
    - 3 - ledger table with value, transaction_id, account_id, ledger_key

## Options considered

1. **How to store a money movement**
   - *Option A: one row = "from account → to account".* Simple for a two-account transfer, but a payment with a fee touches three
     accounts and doesn't fit in one row; nothing groups the pieces of one event.
   - *Option B: entries (one account + signed amount each) grouped by a transaction.* Handles any number of accounts with the same
     structure, and the zero-sum rule becomes checkable: `SUM(amount)` per transaction = 0.
   - **Chosen: B.**

2. **Balance: cached column or always computed**
   - *Computed:* balance = `SUM(amount)` of the account's entries. Always consistent, but gets slow with millions of entries.
   - *Cached:* a `balance` column on `accounts`, updated in the same database transaction as the entries. Fast reads, and the
     account row is the one locked with `FOR UPDATE`. Risk: cache and entries could drift if code updates one without the other.
   - **Chosen: cached**, verified in tests against `SUM(amount)`.

3. **Payment with fee: 3 entries or 4**
   - *3 entries:* clearing −1999, merchant +1946, fees +53. Fewest rows; one clearing line per payment, matching the processor's report.
   - *4 entries:* two pairs (clearing → merchant, clearing → fees). Each pair reads as a simple transfer, but clearing gets two lines per payment.
   - **Chosen: 4 entries.** Each pair shows exactly where each part of the money came from and where it went, which makes
     the movement easier to read and lets each pair be checked to sum to zero on its own.

4. **Where the zero-sum rule is enforced**
   - *Only in Go:* the write path checks the sum before inserting. Simple, but a bug or a manual SQL insert can break it.
   - *Go + deferred constraint trigger:* the database checks the sum at `COMMIT` and rolls back unbalanced transactions. Strongest
     guarantee; costs some SQL logic and a little work per commit.
   - **Chosen: Go + deferred constraint trigger.** Go rejects unbalanced transactions early with a clear error; the trigger is
     the safety net if a bug or a manual insert gets past the code.

## Consequences

- **Cached balance means two writes that must stay in sync.** Every money movement must insert its entries and update
  `accounts.balance` in the same database transaction; if only one of them succeeds, the cache is wrong. Reading a balance
  becomes a single-row read, but every write path has to do both steps, and a test must check that `balance = SUM(amount)`
  for every account.
- **4 entries means reconciliation must sum per payment.** The processor reports one line per payment, while the clearing
  account has two entries for it (merchant share and fee). Reconciliation has to group clearing entries by payment reference
  and sum them before comparing. In return, each pair clearly shows where each part of the money came from and went to.
- **The zero-sum rule lives in two places.** It is written in Go and in the SQL trigger, so changing the rule means changing
  both, and the SQL part is easy to forget because Go tests don't exercise it directly. Every commit also does a little extra
  work. In return, no bug or manual insert can ever save an unbalanced transaction.
