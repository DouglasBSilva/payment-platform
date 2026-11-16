## Context
- The schema should change overtime in a way that allows for the table progress to be observed and to be able to revert some parts of it when needed.

## Decision
- goose with single up/down files.
    - Why: its the one of the most market used tool today so it has a solid foundation and also using plain SQL it easy to find who can maintain that at a later date it also support the use of go so it allows a possible logic to exist.
- CLI as a separated step:
    - it only needs to run once so a deploy will be the time i want it to run, even if it could be run every start when i start expanding horizontally and can have multiple instance i dont need it to run multiples time it should run only once on the deploy before the application starts

## Options Considered:
- golang-migrate and Atlas:
    - Why not Atlas: Its the one with the least adoption of the three and it also dont help with the DDL practice that is one of the main parts of this project.
    - Why not golang-migrate: it marks the version dirty before runing and dont wrap the file in a transaction so when it fails the user need some manual intervention to run it again.

## Consequences:

- this is will make a single file with up/down instead of having the up and down isolated in a single file as allowed in the golang-migrate.
- **Migrations that can't run in a transaction need manual cleanup on failure.** Statements like `CREATE INDEX CONCURRENTLY`
  must be marked `-- +goose NO TRANSACTION`. If one of them fails halfway, part of the change stays applied and the version
  is not recorded, so running it again fails ("already exists") until the leftovers are removed by hand.
- **Each migration holds its locks until it commits.** Because goose wraps the whole migration in one transaction, an
  `ALTER TABLE` keeps its lock until the end. A slow migration on a busy table (e.g. `entries`) blocks writes for that
  whole time, so long data changes should be split into smaller migrations.
- **Go migrations are compiled code.** The standard `goose` CLI can't run them; a custom binary that includes them must be
  built. A Go migration that imports application code can break later when that code changes, so migrations should stay in
  plain SQL unless logic is really needed, and must not import application packages.
- **Migrations created on separate branches can conflict.** With timestamp versions, a migration older than the current
  version is refused unless `-allow-missing` is used. Sequential version numbers (`goose fix`) avoid this, at the cost of
  renumbering when two branches add a migration.
