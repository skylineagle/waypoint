# Add to TREK shortcut

Regenerate the bundled shortcut after changing `AddExpenseIntent` (its identifier, bundle id, or parameter names):

```sh
cd design/shortcut
python3 build-shortcut.py
shortcuts sign --mode anyone --input "Add to TREK.unsigned.shortcut" --output "../../TrekCompanion/Shortcuts/Add to TREK.shortcut"
```

The shortcut runs `Add Expense to Trek` with Amount and Merchant taken from the Shortcut Input, which is the Wallet transaction when it runs from a Transaction automation.
