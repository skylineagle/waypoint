nonisolated enum NextStop {
    static func id(among ids: [Int], done: Set<Int>, after current: Int? = nil) -> Int? {
        let pending = ids.enumerated().filter { !done.contains($0.element) && $0.element != current }
        let reached = [current.flatMap(ids.firstIndex(of:)), ids.lastIndex(where: done.contains)].compactMap(\.self).max() ?? -1
        return (pending.first { $0.offset > reached } ?? pending.first)?.element
    }
}
