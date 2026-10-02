import SwiftUI

struct CostsTotalCard: View {
    let model: CostsModel
    let onShowUnpaid: () -> Void

    private var currency: String { model.converter.displayCurrency }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("TOTAL SPENT")
                .font(.poppins(10, .bold, relativeTo: .caption2))
                .tracking(0.9)
                .foregroundStyle(Color(hex: 0xF5F5F7, alpha: 0.55))
            Text(model.total.money(currency, fractionDigits: 0...0))
                .font(.poppins(32, .bold, relativeTo: .largeTitle))
                .tracking(-0.6)
                .monospacedDigit()
                .contentTransition(.numericText())
            if currency != model.trip.currency {
                Text("≈ \(model.totalInTripCurrency.money(model.trip.currency, fractionDigits: 0...0)) in trip currency")
                    .font(.poppins(12, relativeTo: .caption))
                    .foregroundStyle(Color(hex: 0xF5F5F7, alpha: 0.62))
            }
            if model.isShared {
                shareBar.padding(.top, 10)
            }
            HStack(spacing: 14) {
                if model.hasStarted {
                    stat("Today", model.todayTotal.money(currency, fractionDigits: 0...0))
                    stat("Daily avg", model.dailyAverage.money(currency, fractionDigits: 0...0))
                }
                stat(nil, "\(model.items?.count ?? 0) expenses")
            }
            .padding(.top, model.isShared ? 6 : 10)
            if !model.unpaidItems.isEmpty {
                unpaidButton.padding(.top, 10)
            }
        }
        .foregroundStyle(Color(hex: 0xF5F5F7))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            LinearGradient(colors: [.trekHeroTop, .trekHeroBottom], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: .rect(cornerRadius: 20)
        )
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.trekHeroEdge))
        .animation(.smooth, value: model.total)
    }

    private var shareBar: some View {
        let total = max(model.total, 0.01)
        let shareFraction = min(max(model.myShare / total, 0), 1)
        return VStack(spacing: 6) {
            GeometryReader { proxy in
                Capsule()
                    .fill(Color(hex: 0xF5F5F7, alpha: 0.22))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: 0xF5F5F7))
                            .frame(width: proxy.size.width * shareFraction)
                    }
            }
            .frame(height: 8)
            HStack {
                stat("Your share", model.myShare.money(currency, fractionDigits: 0...0))
                Spacer(minLength: 8)
                stat("Others", max(model.total - model.myShare, 0).money(currency, fractionDigits: 0...0))
            }
        }
        .animation(.smooth, value: model.myShare)
    }

    private var unpaidButton: some View {
        Button(action: onShowUnpaid) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(Color.trekWarning)
                Text("\(model.unpaidItems.count) expenses need a payer")
                    .foregroundStyle(Color(hex: 0xF5F5F7, alpha: 0.72))
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color(hex: 0xF5F5F7, alpha: 0.5))
            }
            .font(.poppins(11.5, relativeTo: .caption))
            .contentShape(.rect)
        }
        .buttonStyle(.borderless)
        .accessibilityHint("Shows the expenses so you can set who paid")
    }

    private func stat(_ label: String?, _ value: String) -> some View {
        HStack(spacing: 4) {
            if let label {
                Text(label).foregroundStyle(Color(hex: 0xF5F5F7, alpha: 0.72))
            }
            Text(value).fontWeight(.semibold)
        }
        .font(.poppins(11.5, relativeTo: .caption))
    }
}
