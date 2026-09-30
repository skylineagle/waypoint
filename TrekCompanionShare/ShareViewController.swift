import SwiftUI
import UIKit

final class ShareViewController: UIViewController {
    private let model = JourneyShareModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        TrekFonts.register()
        let content = JourneyShareView(model: model) { [weak self] in
            self?.model.cleanUp()
            self?.extensionContext?.completeRequest(returningItems: nil)
        }
        let hosting = UIHostingController(rootView: content)
        addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        hosting.didMove(toParent: self)
        let items = extensionContext?.inputItems.compactMap { $0 as? NSExtensionItem } ?? []
        Task { await model.load(items.flatMap { $0.attachments ?? [] }) }
    }
}
