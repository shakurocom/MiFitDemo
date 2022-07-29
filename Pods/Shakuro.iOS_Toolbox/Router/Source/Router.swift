//
// Copyright (c) 2019 Shakuro (https://shakuro.com/)
//

import UIKit

/// The style of navigation to use to present view controller
public enum NavigationStyle {
    case push(asRoot: Bool)
    case modal(transitionStyle: UIModalTransitionStyle?, completion: (() -> Void)?)
    case container(transitionStyle: ContainerViewController.TransitionStyle)
    case splitDetail

    public static let pushDefault: NavigationStyle = .push(asRoot: false)
    public static let modalDefault: NavigationStyle = .modal(transitionStyle: nil, completion:nil)
    public static let modalCrossDissolve: NavigationStyle = .modal(transitionStyle: .crossDissolve, completion:nil)
}

/// - Tag: Router
open class Router: RouterProtocol {

    /// The root navigation controller
    public let rootNavigationController: UINavigationController

     /// The root view controller of root navigation controller
    private(set) public var rootViewController: UIViewController?

     /// true if at least one modal controller is presented
    public var isModalViewControllerOnScreen: Bool {
        return rootNavigationController.presentedViewController != nil
    }

    public init(rootController: UINavigationController) {
        rootNavigationController = rootController
    }

    // MARK: - General

    /// Presents specified view controller using provided style
    /// - Parameters:
    ///   - controller: The UIViewController to present
    ///   - from:The presenting view controller
    ///   - style: presentation (navigation) style
    ///   - animated: true to animate the transition, false to make the transition immediate.
    /// - Returns: newly presented controller in case of success, nil otherwise.
    @discardableResult
    public func presentViewController(controller: UIViewController,
                                      from: UIViewController?,
                                      style: NavigationStyle,
                                      animated: Bool) -> UIViewController? {
        //some of controllers for example MFMessageComposeViewController, can return nil in non optional value even if canSendText() == true
        let uikitBugFixController: UIViewController? = controller
        guard uikitBugFixController != nil else {
            return nil
        }
        switch style {
        case .push(let asRoot):
            let presentingController: UINavigationController = from?.navigationController ?? rootNavigationController
            if asRoot {
                if presentingController === rootNavigationController {
                    rootViewController = controller
                }
                presentingController.setViewControllers([controller], animated: animated)
            } else {
                presentingController.pushViewController(controller, animated: animated)
            }
        case .modal(let transitionStyle, let completion):
            let presentingController: UIViewController = from ?? rootNavigationController
            if let trStyle = transitionStyle {
                controller.modalTransitionStyle = trStyle
            }
            presentingController.present(controller, animated: animated, completion: completion)
        case .container(let transitionStyle):
            if let customContainer: ContainerViewControllerPresenting = from?.lookupCustomContainerViewControllerPresening() {
                customContainer.present(controller, style: transitionStyle, animated: animated)
            } else {
                assertionFailure("\(type(of: self)) - \(#function): CustomContainerViewControllerPresening is nil")
            }
        case .splitDetail:
            let presentingController: UIViewController = from ?? rootNavigationController
            if let splitViewController = presentingController.splitViewController ?? (presentingController as? UISplitViewController) {
                splitViewController.showDetailViewController(controller, sender: presentingController)
                if animated {
                    controller.view.superview?.layer.addTransitionAnimation(duration: 0.2)
                }
            } else {
                assertionFailure("\(type(of: self)) - \(#function): splitViewController is nil")
            }
        }
        return controller
    }

    /// Pops view controllers until view controller with the specified type is at the top of the navigation stack.
    /// - Parameters:
    ///   - controllerType: The type of view controller that you want to be at the top of the stack.
    ///   - sender: The view controller to get navigation controller
    ///   - animated: Set this value to true to animate the transition.
    public func popToFirstViewController<ControllerType>(_ controllerType: ControllerType.Type,
                                                         sender: UIViewController,
                                                         animated: Bool = true) {
        if let navController: UINavigationController = sender.navigationController,
            navController.viewControllers.count > 1 {
            let controllers: [UIViewController] = navController.viewControllers
            for actualController: UIViewController in controllers where (actualController as? ControllerType) != nil {
                navController.popToViewController(actualController, animated: animated)
                break
            }
        }
    }

    /// The same as UINavigationController popToViewController, but with additional check of .viewControllers.count
    public func popToViewController(_ controller: UIViewController, sender: UIViewController, animated: Bool = true) {
        if let navController: UINavigationController = sender.navigationController, navController.viewControllers.count > 1 {
            navController.popToViewController(controller, animated: animated)
        }
    }

    /// Dismisses the view controller that was presented modally or via UINavigationController.
    /// - Parameters:
    ///   - controller: The controller to dismiss
    ///   - animated: Set this value to true to animate the transition.
    public func dismissViewController(_ controller: UIViewController, animated: Bool = true) {
        if let navController: UINavigationController = controller.navigationController, navController.viewControllers.count > 1 {
            if navController.topViewController === controller {
                navController.popViewController(animated: animated)
            }
        } else {
            if let presentingController: UIViewController = controller.presentingViewController {
                presentingController.dismiss(animated: animated, completion: nil)
            } else {
                assertionFailure("dismissViewController: attemt to dismiss not presented ViewController")
            }
        }
    }

    /// Dismisses all view controller that were presented modally.
    public func dismissAllModalViewControllers(_ animated: Bool = true) {
        rootNavigationController.dismiss(animated: animated, completion: nil)
    }

    /// Replaces the view controllers currently managed by the root navigation controller with the specified controller.
    public func setRootViewController(controller: UIViewController, animated: Bool = true) {
        rootViewController = controller
        rootNavigationController.setViewControllers([controller], animated: animated)
    }
}

// MARK: - Private

private extension UIViewController {
    func lookupCustomContainerViewControllerPresening() -> ContainerViewControllerPresenting? {
        return (self as? ContainerViewControllerPresenting) ?? self.containerViewController ?? self.parent?.lookupCustomContainerViewControllerPresening()
    }
}
