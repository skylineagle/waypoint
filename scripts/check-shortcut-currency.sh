#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
swiftc -parse-as-library TrekCompanion/TrekModels.swift ExpenseShared/ExpenseInput.swift TrekCompanion/CurrencyCodeResolver.swift TrekCompanion/AddExpenseIntent.swift TrekCompanion/ExpenseLog.swift Checks/ShortcutCurrency/main.swift -o "$work/check"
"$work/check"
python3 - <<'PY'
import pathlib
import plistlib
import subprocess
import tempfile

script = pathlib.Path("design/shortcut/build-shortcut.py").resolve()
with tempfile.TemporaryDirectory() as directory:
    subprocess.run(["python3", str(script)], cwd=directory, check=True)
    workflow = plistlib.loads((pathlib.Path(directory) / "Add to TREK.unsigned.shortcut").read_bytes())
    parameters = workflow["WFWorkflowActions"][0]["WFWorkflowActionParameters"]
    names = lambda token: [item["PropertyName"] for item in token["Aggrandizements"]]
    assert names(parameters["amount"]["Value"]) == ["Amount"]
    assert names(parameters["currencyCode"]["Value"]["attachmentsByRange"]["{0, 1}"]) == ["Amount"]
print("Wallet shortcut binds amount and currency code separately.")
PY
