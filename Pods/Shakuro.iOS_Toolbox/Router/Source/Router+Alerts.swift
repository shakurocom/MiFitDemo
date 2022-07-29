//
// Copyright (c) 2019 Shakuro (https://shakuro.com/)
//

import UIKit

// MARK: - Alerts

/// - Tag: RouterAlerts
extension Router: RoutingAlertsProtocol {

    public func presentAlert(_ title: String?, message: String?, sender: UIViewController?, animated: Bool) {
        let action = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil)
        presentAlert(title,
                     message: message,
                     actions: [action],
                     sender: sender,
                     animated: animated)
    }

    public func presentAlert(_ title: String?, message: String?, actions: [UIAlertAction], sender: UIViewController?, animated: Bool) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach({ alertController.addAction($0) })
        let presentingController: UIViewController
        if let actualSender = sender {
            presentingController = actualSender.view.window != nil ? actualSender : rootNavigationController
        } else {
            presentingController = rootNavigationController
        }
        presentingController.present(alertController, animated: animated, completion: nil)
    }

    public func presentActionSheet(_ title: String?,
                                   message: String?,
                                   actions: [UIAlertAction],
                                   sender: UIViewController?,
                                   popoverSourceView: UIView?,
                                   animated: Bool) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actions.forEach({ alertController.addAction($0) })
        if let sourceView = popoverSourceView {
            alertController.modalPresentationStyle = .popover
            if let popoverPresentationController = alertController.popoverPresentationController {
                popoverPresentationController.sourceView = sourceView
                popoverPresentationController.sourceRect = sourceView.bounds
            }
        }
        let presentingController: UIViewController
        if let actualSender = sender {
            presentingController = actualSender.view.window != nil ? actualSender : rootNavigationController
        } else {
            presentingController = rootNavigationController
        }
        presentingController.present(alertController, animated: animated, completion: nil)
    }
}

// MARK: - Error Handling

extension Router {

    public func presentErrorAlert(_ error: PresentableError, sender: UIViewController?, animated: Bool) {
        presentErrorAlert(error.errorDescription, sender: sender, animated: animated)
    }

    public func presentErrorAlert(_ error: PresentableError,
                                  actions: [UIAlertAction],
                                  sender: UIViewController?,
                                  animated: Bool) {
        presentErrorAlert(error.errorDescription,
                          actions: actions,
                          sender: sender,
                          animated: animated)
    }

    public func presentErrorAlert(_ errorMessage: String,
                                  sender: UIViewController?,
                                  animated: Bool) {
        let action = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil)
        presentErrorAlert(errorMessage,
                          actions: [action],
                          sender: sender,
                          animated: animated)
    }

    public func presentErrorAlert(_ errorMessage: String,
                                  actions: [UIAlertAction],
                                  sender: UIViewController?,
                                  animated: Bool) {
        presentAlert(NSLocalizedString("Oops!", comment: ""),
                     message: errorMessage,
                     actions: actions,
                     sender: sender,
                     animated: animated)
    }
}
