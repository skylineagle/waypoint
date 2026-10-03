import AppIntents
import SwiftUI
import WidgetKit

struct ScanReceiptControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "ScanReceiptControl") {
            ControlWidgetButton(action: OpenURLIntent(URL(string: "trekcompanion://scan-receipt")!)) {
                Label("Scan Receipt", systemImage: "doc.text.viewfinder")
            }
        }
        .displayName("Scan Receipt")
        .description("Snap a receipt and log it as a Waypoint expense.")
    }
}
