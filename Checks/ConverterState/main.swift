import Foundation

enum AppGroup {
    static let defaults = UserDefaults.standard
}

func check(_ condition: Bool, _ label: String) {
    precondition(condition, label)
    print("ok  \(label)")
}

var state = ConverterState(tripTitle: "Thailand", tripCurrency: "THB", displayCurrency: "EUR", rate: 0.0262, entry: "100", lastKeyAt: nil)

state.step(1)
check(state.entry == "200", "up from 100 goes to 200")
state.step(-1); state.step(-1)
check(state.entry == "50", "down twice from 200 goes to 50")

state.entry = "340"
state.step(1)
check(state.entry == "500", "off-ladder amount snaps up")
state.entry = "340"
state.step(-1)
check(state.entry == "200", "off-ladder amount snaps down")
state.entry = "1"
state.step(-1)
check(state.entry == "1", "ladder floor stays at 1")

state.entry = "340"
let start = Date(timeIntervalSince1970: 1000)
state.type("1", at: start)
check(state.entry == "1", "first stroke replaces the existing amount")
"2.5".map(String.init).forEach { state.type($0, at: start.addingTimeInterval(1)) }
check(state.entry == "12.5" && state.amount == 12.5, "keypad builds a decimal")
state.type(".", at: start.addingTimeInterval(2))
check(state.entry == "12.5", "second decimal point ignored")
state.type("7", at: start.addingTimeInterval(20))
check(state.entry == "7", "stroke after a pause starts a new number")
state.type("⌫", at: start.addingTimeInterval(21))
check(state.entry == "0", "delete on last digit resets to 0")

check(abs(ConverterState(tripTitle: "", tripCurrency: "THB", displayCurrency: "EUR", rate: 0.0262, entry: "500", lastKeyAt: nil).converted - 13.1) < 0.001, "converted uses rate")
print("all converter checks passed")
