import SwiftUI

struct NoteMarkdown: View {
    let text: String

    private var lines: [(id: Int, bullet: String?, content: AttributedString)] {
        text.split(separator: "\n", omittingEmptySubsequences: false).enumerated().map { index, raw in
            let line = raw.trimmingCharacters(in: .whitespaces)
            let bullet: String?
            let body: Substring
            if line.hasPrefix("- ") || line.hasPrefix("* ") {
                bullet = "•"
                body = line.dropFirst(2)
            } else if let dot = line.firstIndex(of: "."), line[..<dot].allSatisfy(\.isNumber), !line[..<dot].isEmpty, line[dot...].hasPrefix(". ") {
                bullet = String(line[...dot])
                body = line[line.index(dot, offsetBy: 2)...]
            } else {
                bullet = nil
                body = Substring(line)
            }
            let content = (try? AttributedString(markdown: String(body), options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(body)
            return (index, bullet, content)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(lines, id: \.id) { line in
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    if let bullet = line.bullet { Text(bullet) }
                    Text(line.content)
                }
            }
        }
    }
}
