//
// Copyright (c) 2019 Shakuro (https://shakuro.com/)
//

import SafariServices
import UIKit

/// Router public interface see [Router](x-source-tag://Router)
public protocol RouterProtocol: class {

    var isModalViewControllerOnScreen: Bool { get }

    @discardableResult
    func presentViewController(controller: UIViewController,
                               from: UIViewController?,
                               style: NavigationStyle,
                               animated: Bool) -> UIViewController?

    func popToViewController(_ controller: UIViewController, sender: UIViewController, animated: Bool)
    func popToFirstViewController<ControllerType>(_ controllerType: ControllerType.Type,
                                                  sender: UIViewController,
                                                  animated: Bool)

    func dismissViewController(_ controller: UIViewController, animated: Bool)

}

/// SFSafariViewController support protocol see [Router+URL](x-source-tag://RouterURL)
public protocol RoutingURLProtocol: class {
    @discardableResult
    func presentURL(_ sender: UIViewController, options: SafariViewControllerOptions) -> SFSafariViewController?
}

/// Alerts support protocol see [Router+Alert](x-source-tag://RouterAlerts)
public protocol RoutingAlertsProtocol: class {

    func presentActionSheet(_ title: String?,
                            message: String?,
                            actions: [UIAlertAction],
                            sender: UIViewController?,
                            popoverSourceView: UIView?,
                            animated: Bool)

    func presentAlert(_ title: String?, message: String?, actions: [UIAlertAction], sender: UIViewController?, animated: Bool)
    func presentAlert(_ title: String?, message: String?, sender: UIViewController?, animated: Bool)

    func presentErrorAlert(_ error: PresentableError, sender: UIViewController?, animated: Bool)
    func presentErrorAlert(_ error: PresentableError,
                           actions: [UIAlertAction],
                           sender: UIViewController?,
                           animated: Bool)
    func presentErrorAlert(_ errorMessage: String,
                           sender: UIViewController?,
                           animated: Bool)
    func presentErrorAlert(_ errorMessage: String,
                           actions: [UIAlertAction],
                           sender: UIViewController?,
                           animated: Bool)

}
