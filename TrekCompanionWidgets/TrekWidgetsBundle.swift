import SwiftUI
import WidgetKit

@main
struct TrekWidgetsBundle: WidgetBundle {
    var body: some Widget {
        NextStopWidget()
        SpentTodayWidget()
        ConverterWidget()
        TripActivityWidget()
    }
}
