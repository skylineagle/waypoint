import SwiftUI

struct ShareReceiptRow: View {
    @Binding var receipt: ShareReceipt
    let fallbackCurrency: String?
    @State private var isEditing = false

    private var currency: String? { receipt.currency ?? fallbackCurrency }

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 10) {
                if let thumbnail = JourneyPhoto.thumbnail(receipt.file) {
                    Image(uiImage: thumbnail).resizable().scaledToFill()
                        .frame(width: 44, height: 56).clipShape(.rect(cornerRadius: 8))
                        .accessibilityHidden(true)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(receipt.name.isEmpty ? "Unnamed receipt" : receipt.name)
                        .font(.poppins(15, .semibold)).lineLimit(1)
                    HStack(spacing: 6) {
                        Text(receipt.date, format: .dateTime.month(.abbreviated).day()).fixedSize()
                        Label(receipt.category.label, systemImage: receipt.category.symbol)
                            .foregroundStyle(receipt.category.color)
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .font(.poppins(12)).foregroundStyle(Color.trekMuted)
                }
                Spacer(minLength: 4)
                VStack(alignment: .trailing, spacing: 0) {
                    Text(receipt.amount.map { $0.formatted(.number.precision(.fractionLength(0...2))) } ?? "–")
                        .font(.poppins(17, .bold)).monospacedDigit()
                        .lineLimit(1).fixedSize()
                    if let currency {
                        Text(currency).font(.poppins(11, .bold)).foregroundStyle(Color.trekMuted)
                    }
                }
            }
            .opacity(receipt.isExpense ? 1 : 0.45)
            Button("Edit expense", systemImage: "pencil") { isEditing = true }
                .labelStyle(.iconOnly)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 34, height: 34)
                .background(Color.trekSecondaryFill, in: .circle)
                .buttonStyle(.plain)
                .disabled(!receipt.isExpense)
            Toggle("Add as expense", isOn: $receipt.isExpense).labelsHidden()
        }
        .padding(12)
        .background(Color.trekInput, in: .rect(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.trekBorder, lineWidth: 1))
        .sheet(isPresented: $isEditing) {
            ShareReceiptEditor(receipt: $receipt, fallbackCurrency: fallbackCurrency)
        }
    }
}
