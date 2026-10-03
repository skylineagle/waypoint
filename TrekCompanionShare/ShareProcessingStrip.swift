import SwiftUI

struct ShareProcessingStrip: View {
    let queue: [QueuedPhoto]
    let processedCount: Int

    var body: some View {
        VStack(spacing: 8) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(Array(queue.enumerated()), id: \.element.id) { index, item in
                            thumbnail(item, index: index).id(item.id)
                        }
                    }
                    .padding(4)
                }
                .scrollIndicators(.hidden)
                .onChange(of: processedCount) { _, current in
                    guard queue.indices.contains(current) else { return }
                    withAnimation(.smooth) { proxy.scrollTo(queue[current].id, anchor: .center) }
                }
            }
            Text(queue.isEmpty ? "Preparing photos…" : "Reading photo \(min(processedCount + 1, queue.count)) of \(queue.count)")
                .font(.poppins(13)).foregroundStyle(Color.trekMuted)
            ProgressView(value: Double(processedCount), total: Double(max(queue.count, 1)))
                .tint(Color.trekAccent)
        }
    }

    private func thumbnail(_ item: QueuedPhoto, index: Int) -> some View {
        let isDone = index < processedCount
        let isCurrent = index == processedCount
        return Group {
            if let image = item.thumbnail {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Color.trekSecondaryFill
            }
        }
        .frame(width: 52, height: 52)
        .clipShape(.rect(cornerRadius: 10))
        .opacity(isDone ? 0.35 : 1)
        .overlay {
            if isCurrent {
                ProgressView().tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black.opacity(0.35), in: .rect(cornerRadius: 10))
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12).stroke(Color.trekAccent, lineWidth: 2).padding(-3)
                .opacity(isCurrent ? 1 : 0)
        }
        .overlay(alignment: .bottomTrailing) {
            if isDone {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.trekSuccess)
                    .background(Color.trekCard, in: .circle).offset(x: 4, y: 4)
            }
        }
        .animation(.smooth, value: processedCount)
        .accessibilityLabel(isDone ? "Photo read" : isCurrent ? "Reading photo" : "Waiting")
    }
}
