import Foundation
import Vision

struct ReceiptRow {
    let text: String
    let height: Double
}

enum ReceiptRows {
    private struct Block {
        let text: String
        let minX: Double
        let midX: Double
        let height: Double
        let bottomLeft: (x: Double, y: Double)
        let bottomRight: (x: Double, y: Double)

        var width: Double {
            bottomRight.x - bottomLeft.x
        }

        var slope: Double {
            width > 0.0001 ? (bottomRight.y - bottomLeft.y) / width : 0
        }

        func baselineY(at x: Double, slope: Double) -> Double {
            bottomLeft.y + slope * (x - bottomLeft.x)
        }
    }

    static func rows(from observations: [RecognizedTextObservation]) -> [ReceiptRow] {
        let blocks = observations.compactMap(block(from:)).sorted { $0.bottomLeft.y > $1.bottomLeft.y }
        let slope = pageSlope(of: blocks)
        var rows: [[Block]] = []
        for block in blocks {
            let match = rows.indices
                .map { index in (index, distance(of: block, to: rows[index][0], slope: slope)) }
                .filter { $0.1 < 0.5 }
                .min { $0.1 < $1.1 }
            if let match {
                rows[match.0].append(block)
            } else {
                rows.append([block])
            }
        }
        return rows.map { blocks in
            let ordered = blocks.sorted { $0.minX < $1.minX }
            return ReceiptRow(text: ordered.map(\.text).joined(separator: "  "), height: ordered.map(\.height).max() ?? 0)
        }
    }

    private static func pageSlope(of blocks: [Block]) -> Double {
        let slopes = blocks.filter { $0.width > 0.2 }.map(\.slope).sorted()
        return slopes.isEmpty ? 0 : slopes[slopes.count / 2]
    }

    private static func distance(of block: Block, to anchor: Block, slope: Double) -> Double {
        let lineHeight = min(block.height, anchor.height)
        guard lineHeight > 0 else { return .infinity }
        return abs(anchor.baselineY(at: block.midX, slope: slope) - block.baselineY(at: block.midX, slope: slope)) / lineHeight
    }

    private static func block(from observation: RecognizedTextObservation) -> Block? {
        guard let text = observation.topCandidates(1).first?.string else { return nil }
        let bottomLeft = (x: Double(observation.bottomLeft.x), y: Double(observation.bottomLeft.y))
        let bottomRight = (x: Double(observation.bottomRight.x), y: Double(observation.bottomRight.y))
        let height = hypot(Double(observation.topLeft.x - observation.bottomLeft.x), Double(observation.topLeft.y - observation.bottomLeft.y))
        return Block(
            text: text,
            minX: min(bottomLeft.x, Double(observation.topLeft.x)),
            midX: (bottomLeft.x + bottomRight.x) / 2,
            height: height,
            bottomLeft: bottomLeft,
            bottomRight: bottomRight
        )
    }
}
