#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
swiftc -parse-as-library TrekCompanion/TrekModels.swift TrekCompanion/AddExpenseIntent.swift Checks/ShortcutCurrency/main.swift -o "$work/check"
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
    amount = workflow["WFWorkflowActions"][0]["WFWorkflowActionParameters"]["amount"]["Value"]
    assert amount["Aggrandizements"] == [{"PropertyName": "Amount", "Type": "WFPropertyVariableAggrandizement"}]
print("Wallet shortcut passes the currency amount without number coercion.")
PY
