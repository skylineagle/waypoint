import PhotosUI
import SwiftUI

struct ExpenseEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let item: BudgetItem?
    let converter: CurrencyConverter
    let members: [TripMember]
    let meID: Int?
    let startsScanning: Bool
    let onSave: (ExpenseInput, _ receipt: Data?) async throws -> Void
    let onDelete: () async -> Void

    @State private var name: String
    @State private var amount: Double?
    @State private var currency: String
    @State private var category: CostCategory
    @State private var date: Date
    @State private var note: String
    @State private var payerID: Int?
    @State private var splitIDs: Set<Int>
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var receiptImage: UIImage?
    @State private var isScanning = false
    @State private var isPickingPhoto = false
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var isReadingReceipt = false
    @FocusState private var isAmountFocused: Bool

    init(
        item: BudgetItem?,
        converter: CurrencyConverter,
        members: [TripMember],
        meID: Int?,
        startsScanning: Bool = false,
        onSave: @escaping (ExpenseInput, _ receipt: Data?) async throws -> Void,
        onDelete: @escaping () async -> Void
    ) {
        self.item = item
        self.converter = converter
        self.members = members
        self.meID = meID
        self.startsScanning = startsScanning
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: item?.name ?? "")
        _amount = State(initialValue: item?.totalPrice)
        _currency = State(initialValue: (item?.currency ?? converter.tripCurrency).uppercased())
        _category = State(initialValue: item?.costCategory ?? .food)
        _date = State(initialValue: ExpenseDate.date(from: item?.expenseDate) ?? .now)
        _note = State(initialValue: item?.note ?? "")
        let existingPayer = item?.payers?.first { $0.amount != 0 }?.userId
        _payerID = State(initialValue: item == nil ? meID : existingPayer)
        if let item {
            _splitIDs = State(initialValue: Set((item.members ?? []).map(\.userId)))
        } else {
            _splitIDs = State(initialValue: Set(members.map(\.id)))
        }
    }

    private var isShared: Bool {
        members.count > 1
    }

    private func payerInputs(amount: Double) -> [ExpenseInput.PayerInput]? {
        guard isShared else { return nil }
        guard let payerID else { return [] }
        return [ExpenseInput.PayerInput(userId: payerID, amount: amount)]
    }

    private var perPerson: String? {
        guard let amount, !splitIDs.isEmpty else { return nil }
        return (converter.convert(amount, from: currency) / Double(splitIDs.count)).money(converter.displayCurrency)
    }

    private var currencies: [String] {
        [converter.tripCurrency, converter.displayCurrency, currency].reduce(into: []) { list, code in
            if !list.contains(code) { list.append(code) }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && (amount ?? 0) > 0 && !isSaving
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if ReceiptParser.isAvailable {
                        ReceiptTile(
                            image: receiptImage,
                            savedCount: item?.receipts?.count ?? 0,
                            isReading: isReadingReceipt,
                            onScan: DocumentScanner.isAvailable ? { isScanning = true } : nil,
                            onChoosePhoto: { isPickingPhoto = true }
                        )
                    }
                    TrekTextField(symbol: "pencil", placeholder: "What was it?", text: $name, accessibilityLabel: "Name")
                    HStack(spacing: 8) {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.trekInput, in: .rect(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.trekBorder))
                        TrekTextField(symbol: "note.text", placeholder: "Note", text: $note, accessibilityLabel: "Note")
                    }
                    if isShared {
                        ExpenseSplitSection(members: members, meID: meID, perPerson: perPerson, payerID: $payerID, splitIDs: $splitIDs)
                    }
                    CardCaption(text: "Category")
                        .padding(.top, 8)
                    CategoryGrid(selection: $category)
                    if let errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.circle")
                            .font(.poppins(13, relativeTo: .footnote))
                            .foregroundStyle(Color.trekDanger)
                    }
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Color.trekBackground)
        .stepActions {
            Button(item == nil ? "Add expense" : "Save changes", action: save)
                .buttonStyle(TrekButtonStyle())
                .disabled(!canSave)
            if item != nil {
                Button("Delete expense", role: .destructive) {
                    Task {
                        await onDelete()
                        dismiss()
                    }
                }
                .font(.poppins(15, .semibold))
                .foregroundStyle(Color.trekDanger)
                .frame(minHeight: 36)
            }
        }
        .fullScreenCover(isPresented: $isScanning) {
            DocumentScanner(onScan: readReceipt).ignoresSafeArea()
        }
        .photosPicker(isPresented: $isPickingPhoto, selection: $pickedPhoto, matching: .images)
        .onChange(of: pickedPhoto) { _, photo in
            guard let photo else { return }
            pickedPhoto = nil
            Task {
                if let data = try? await photo.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                    readReceipt(image)
                }
            }
        }
        .onAppear {
            if startsScanning {
                if DocumentScanner.isAvailable { isScanning = true } else { isPickingPhoto = true }
            } else {
                isAmountFocused = item == nil
            }
        }
    }

    private var header: some View {
        VStack(spacing: 14) {
            HStack {
                circleButton("Cancel", symbol: "xmark", filled: false) { dismiss() }
                Spacer()
                Text(item == nil ? "New expense" : "Edit expense")
                    .font(.poppins(15, .semibold, relativeTo: .headline))
                    .foregroundStyle(Color.trekText)
                Spacer()
                circleButton("Save", symbol: "checkmark", filled: true, action: save)
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.35)
            }
            HStack(spacing: 10) {
                Image(systemName: category.symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(category.color, in: .rect(cornerRadius: 14))
                    .accessibilityHidden(true)
                TextField("0", value: $amount, format: .number.precision(.fractionLength(0...2)))
                    .font(.poppins(34, .bold, relativeTo: .largeTitle))
                    .foregroundStyle(Color.trekText)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .focused($isAmountFocused)
                    .monospacedDigit()
                    .accessibilityLabel("Amount")
                Menu {
                    Picker("Currency", selection: $currency) {
                        ForEach(currencies, id: \.self) { Text($0) }
                    }
                } label: {
                    HStack(spacing: 3) {
                        Text(currency)
                        Image(systemName: "chevron.down").font(.system(size: 9, weight: .bold))
                    }
                    .font(.poppins(12, .bold, relativeTo: .caption))
                    .foregroundStyle(Color.trekAccentText)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 7)
                    .background(Color.trekAccent, in: .rect(cornerRadius: 9))
                }
                .accessibilityLabel("Currency \(currency)")
            }
            if let amount, currency != converter.displayCurrency {
                Text("≈ \(converter.convert(amount, from: currency).money(converter.displayCurrency))")
                    .font(.poppins(12, relativeTo: .caption))
                    .foregroundStyle(Color.trekMuted)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(16)
        .background(category.color.opacity(0.12))
        .animation(.smooth, value: category)
    }

    @ViewBuilder
    private func circleButton(_ label: String, symbol: String, filled: Bool, action: @escaping () -> Void) -> some View {
        let button = Button(label, systemImage: symbol, action: action)
            .labelStyle(.iconOnly)
            .font(.system(size: 15, weight: .bold))
            .buttonBorderShape(.circle)
            .controlSize(.large)
        if filled {
            button.buttonStyle(.glassProminent).tint(Color.trekAccent).foregroundStyle(Color.trekAccentText)
        } else {
            button.buttonStyle(.glass).foregroundStyle(Color.trekText)
        }
    }

    private func readReceipt(_ image: UIImage) {
        receiptImage = image
        isReadingReceipt = true
        Task {
            defer { isReadingReceipt = false }
            let details = await ReceiptReader.details(of: image)
            if amount == nil { amount = details.total }
            guard item == nil else { return }
            if let currency = details.currency { self.currency = currency }
            if let date = details.date { self.date = date }
            if name.trimmingCharacters(in: .whitespaces).isEmpty, let merchant = details.merchant {
                name = merchant.capitalized
                category = await ExpenseCategorizer.category(for: merchant)
            }
            if amount == nil { isAmountFocused = true }
        }
    }

    private func save() {
        guard canSave, let amount else { return }
        let input = ExpenseInput(
            name: name.trimmingCharacters(in: .whitespaces),
            category: category.rawValue,
            totalPrice: amount,
            currency: currency,
            note: note,
            expenseDate: ExpenseDate.format.format(date),
            payers: payerInputs(amount: amount),
            memberIds: isShared ? splitIDs.sorted() : nil
        )
        isSaving = true
        errorMessage = nil
        Task {
            defer { isSaving = false }
            do {
                try await onSave(input, receiptImage?.jpegData(compressionQuality: 0.6))
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
