//
// Copyright (c) 2019 Shakuro (https://shakuro.com/)
//

import SafariServices
import UIKit

public struct SafariViewControllerOptions {
    static let validSchema: [String] = ["http", "https"]

    public let URI: URL

    private(set) weak public var delegate: SFSafariViewControllerDelegate?

    public func canOpenViaSafariViewController() -> Bool {
        return SafariViewControllerOptions.validSchema.contains(URI.scheme?.lowercased() ?? "")
    }

    public init(URI: URL) {
        self.URI = URI
        self.delegate = nil
    }
}

public final class SafariViewController: SFSafariViewController {

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension SFSafariViewController {

    public static func present(_ sender: UIViewController,
                               router: RouterProtocol,
                               options: SafariViewControllerOptions) -> SFSafariViewController? {
        let controller: SafariViewController = SafariViewController(url: options.URI)
        controller.delegate = options.delegate
        return router.presentViewController(controller: controller,
                                            from: sender,
                                            style: .modalDefault,
                                            animated: true) as? SFSafariViewController
    }
}
