func check(_ condition: Bool, _ label: String) {
    precondition(condition, label)
    print("ok  \(label)")
}

let day = [1, 2, 3, 4, 5]

check(NextStop.id(among: day, done: []) == 1, "a fresh day starts at the first stop")
check(NextStop.id(among: day, done: [1, 2]) == 3, "done in order moves on to the following stop")
check(NextStop.id(among: day, done: [3]) == 4, "skipping ahead leaves the skipped stops behind")
check(NextStop.id(among: day, done: [1, 4]) == 5, "the latest done stop decides where the day is")
check(NextStop.id(among: day, done: [5]) == 1, "after the last stop, the earliest skipped one is next")
check(NextStop.id(among: day, done: Set(day)) == nil, "a finished day has no next stop")
check(NextStop.id(among: day, done: [], after: 3) == 4, "standing at a stop, the one after it comes next")
check(NextStop.id(among: day, done: [4], after: 2) == 5, "standing at a skipped stop does not rewind the day")
check(NextStop.id(among: day, done: [1, 2, 3, 4], after: 5) == nil, "standing at the last stop leaves nothing after it")
