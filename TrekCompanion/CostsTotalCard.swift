import SwiftUI

struct CostsTotalCard: View {
    let model: CostsModel

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
                HStack(spacing: 14) {
                    stat("Your share", model.myShare.money(currency, fractionDigits: 0...0))
                    stat("You paid", model.myPaid.money(currency, fractionDigits: 0...0))
                }
                .padding(.top, 10)
            }
            HStack(spacing: 14) {
                if model.hasStarted {
                    stat("Today", model.todayTotal.money(currency, fractionDigits: 0...0))
                    stat("Daily avg", model.dailyAverage.money(currency, fractionDigits: 0...0))
                }
                stat(nil, "\(model.items?.count ?? 0) expenses")
            }
            .padding(.top, model.isShared ? 4 : 10)
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
