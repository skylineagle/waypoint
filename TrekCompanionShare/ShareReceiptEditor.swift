import SwiftUI

struct ShareReceiptEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var receipt: ShareReceipt
    let fallbackCurrency: String?
    @State private var draft: ShareReceipt
    @State private var currency: String
    @FocusState private var isAmountFocused: Bool

    init(receipt: Binding<ShareReceipt>, fallbackCurrency: String?) {
        _receipt = receipt
        self.fallbackCurrency = fallbackCurrency
        _draft = State(initialValue: receipt.wrappedValue)
        _currency = State(initialValue: receipt.wrappedValue.currency ?? fallbackCurrency ?? "")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if let image = JourneyPhoto.thumbnail(draft.file) {
                        Image(uiImage: image).resizable().scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 220)
                            .clipShape(.rect(cornerRadius: 12))
                            .accessibilityLabel("Receipt photo")
                    }
                    HStack(spacing: 10) {
                        CategoryTile(category: draft.category, size: 46)
                        TextField("0", value: $draft.amount, format: .number.precision(.fractionLength(0...2)))
                            .font(.poppins(34, .bold, relativeTo: .largeTitle))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .monospacedDigit()
                            .focused($isAmountFocused)
                            .accessibilityLabel("Amount")
                        TextField("CUR", text: $currency)
                            .font(.poppins(13, .bold, relativeTo: .caption))
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .frame(width: 52)
                            .padding(.vertical, 7)
                            .multilineTextAlignment(.center)
                            .background(Color.trekInput, in: .rect(cornerRadius: 9))
                            .accessibilityLabel("Currency")
                    }
                    .padding(.vertical, 6)
                    TrekTextField(symbol: "pencil", placeholder: "What was it?", text: $draft.name, accessibilityLabel: "Name")
                    DatePicker("Date", selection: $draft.date, displayedComponents: .date)
                        .font(.poppins(15))
                        .padding(.horizontal, 14)
                        .frame(minHeight: 50)
                        .background(Color.trekInput, in: .rect(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.trekBorder))
                    CardCaption(text: "Category").padding(.top, 8)
                    CategoryGrid(selection: $draft.category)
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.trekCard)
            .navigationTitle("Edit expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark", action: save).disabled(!draft.canAdd)
                }
            }
            .onAppear { isAmountFocused = draft.amount == nil }
        }
    }

    private func save() {
        let code = currency.trimmingCharacters(in: .whitespaces).uppercased()
        draft.currency = code.count == 3 ? code : nil
        receipt = draft
        dismiss()
    }
}
