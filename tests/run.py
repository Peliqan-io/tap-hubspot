import sys
sys.path.insert(1, '..')
import tap_hubspot

tap_hubspot.main()

# Run discovery mode: python3 run.py --discover --config config.json > catalog.json
# Run sync mode: python3 run.py --config config.json --catalog catalog.json --state state.json
# Sync to target: python3 run.py --config config.json --catalog catalog.json --state state.json | target-postgres --config target_config.json