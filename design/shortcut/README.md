# Add to TREK shortcut

Regenerate the bundled shortcut after changing `AddExpenseIntent` (its identifier, bundle id, or parameter names):

```sh
cd design/shortcut
python3 build-shortcut.py
shortcuts sign --mode anyone --input "Add to TREK.unsigned.shortcut" --output "Waypoint - TREK Expenses.shortcut"
```

The shortcut includes a Wallet trigger for any card, with no confirmation. Amount is the Wallet currency amount, preserving its value and ISO currency code, and Merchant is the transaction merchant. Do not convert Amount to a number. Share the signed file from Shortcuts and put the new iCloud link in `TrekShortcut.link`. Existing installations need the updated shortcut.

Run `bash scripts/check-shortcut-currency.sh` from the repository root to check expense currency forwarding and the generated Wallet input mapping.

For simulator testing, create a shortcut with `Add Expense to Trek`, Amount `12.34 ILS`, and Merchant `Starbucks Test`. Select a trip using another currency, run the shortcut, and verify the saved expense still uses ILS. Each run creates a real server expense. This tests the app action; the Wallet trigger and transaction input still need a real iPhone payment.
