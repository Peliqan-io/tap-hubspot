# tap-hubspot — Python 3.11 Regression Tests

Before/after parity test for the Python 3.9 → 3.11 migration.

## Why this exists

The original 3.11 audit flagged tap-hubspot as MEDIUM-effort with a single open question:

> Install & import verified on Python 3.11.15 in `install_test` — but needs live system test (real HubSpot sync) before confirming safe.

This regression suite **is** that live system test. It runs a real HubSpot OAuth sync on both Python 3.9 and Python 3.11 and asserts schemas / state-key names / record fields are byte-identical between the two.

## Files

| File | Purpose |
| --- | --- |
| `conftest.py` | Config builder, catalog filtering, sync runner, message parser |
| `capture.py` | Standalone — run once on Python 3.9 to write `baseline/` |
| `test_regression.py` | pytest suite — run on Python 3.11 to verify parity |
| `run_capture.sh` / `run_tests.sh` | Docker wrappers (python:3.9-slim / python:3.11-slim) |
| `baseline/` | Committed reference output (schemas, state keys, record fields, catalog, meta) |

## Usage

Required env vars:

```bash
export TAP_HUBSPOT_CLIENT_ID=...
export TAP_HUBSPOT_CLIENT_SECRET=...
export TAP_HUBSPOT_REFRESH_TOKEN=...
export TAP_HUBSPOT_REDIRECT_URI=https://oauth.peliqan.io/   # optional, default
export TAP_HUBSPOT_INCLUDE_STREAMS=companies,contacts        # comma-separated, default
export TAP_HUBSPOT_START_DATE=2024-01-01T00:00:00Z           # optional
```

### Capture baseline (pre-migration code on Python 3.9)

```bash
git worktree add /tmp/tap-hubspot-master master
cp -r tests/regression /tmp/tap-hubspot-master/tests/regression
cd /tmp/tap-hubspot-master
bash tests/regression/run_capture.sh
cp -r tests/regression/baseline /path/to/migration-branch/tests/regression/
git worktree remove /tmp/tap-hubspot-master
```

### Run tests (migration branch on Python 3.11)

```bash
bash tests/regression/run_tests.sh
```

## Notes

- tap-hubspot has ~30 streams and contacts has 1600+ properties. `TAP_HUBSPOT_INCLUDE_STREAMS` filters to the chosen subset (default `companies,contacts`) to keep sync time reasonable.
- The Peliqan backend `tap_hubspot.py` strips most `property_hs_*` fields from the catalog before sync. This regression suite does **not** apply that filter — it tests the raw tap output. If you want production-mirroring behaviour, add the same filter to `conftest.select_streams()`.
- OAuth client is **per-portal**, not per-user. The same client_id/secret pair works for any HubSpot portal a user authorizes against.
