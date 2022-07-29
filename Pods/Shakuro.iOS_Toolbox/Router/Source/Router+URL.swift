//
// Copyright (c) 2019 Shakuro (https://shakuro.com/)
//

import SafariServices
import UIKit

/// - Tag: RouterURL
extension Router: RoutingURLProtocol {
    @discardableResult
    public func presentURL(_ sender: UIViewController, options: SafariViewControllerOptions) -> SFSafariViewController? {
        if options.canOpenViaSafariViewController() {
            return SFSafariViewController.present(sender,
                                                  router: self,
                                                  options: options)
        } else {
            debugPrint("can't present SafariViewController for URI: \(options.URI)")
            UIApplication.shared.open(options.URI, options: [:], completionHandler: nil)
            return nil
        }
    }
}
