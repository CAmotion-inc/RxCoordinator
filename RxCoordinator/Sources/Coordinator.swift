//
//  Coordinator.swift
//  RxCoordinator
//
//  Created by Stefan Kofler on 30.04.18.
//  Copyright © 2018 Stefan Kofler. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

public typealias Completion = (() -> ())?

public protocol Coordinator: class, Presentable {
    associatedtype CoordinatorRoute: Route

    var context: UIViewController! { get }
    var rootViewController: UIViewController { get }

    func transition(to route: CoordinatorRoute, with options: TransitionOptions)

    func presented(from presentable: Presentable?)
}

extension Coordinator {

    public var viewController: UIViewController! {
        return rootViewController
    }

    var navigationController: UINavigationController {
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        return viewController.navigationController!
    }

    public func presented(from presentable: Presentable?) {}

    public func transition(to route: CoordinatorRoute, with options: TransitionOptions) {
        let transition = route.prepareTransition(coordinator: AnyCoordinator(self))
        self.performTransition(transition, with: options)
    }

    // MARK: Convenience methods

    public func transition(to route: CoordinatorRoute) {
        transition(to: route, with: TransitionOptions.defaultOptions)
    }

    // MARK: Transitions

    func bump(completion: Completion) {
        completion?()
    }

    func presentAlert(_ viewController: UIViewController, with options: TransitionOptions, completion: Completion) {
        rootViewController.present(viewController, animated: options.animated, completion: completion)
    }

    func present(_ viewController: UIViewController, with options: TransitionOptions, animation: Animation?, completion: Completion) {
        viewController.transitioningDelegate = animation
        rootViewController.present(viewController, animated: options.animated, completion: completion)
    }

    func dismiss(with options: TransitionOptions, animation: Animation?, completion: Completion) {
        context.presentedViewController?.transitioningDelegate = animation
        context.presentedViewController?.dismiss(animated: true, completion: completion)
    }

    func embed(_ viewController: UIViewController, in container: Container, to index: Int, with options: TransitionOptions, completion: Completion) {
        container.viewController.addChild(viewController)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        container.view.insertSubview(viewController.view, at: index)
        
        container.view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor).isActive = true
        container.view.rightAnchor.constraint(equalTo: viewController.view.rightAnchor).isActive = true
        container.view.topAnchor.constraint(equalTo: viewController.view.topAnchor).isActive = true
        container.view.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor).isActive = true
        
        viewController.didMove(toParent: container.viewController)
        completion?()
    }

    func embed(_ viewController: UIViewController, in container: Container, with options: TransitionOptions, completion: Completion) {
        container.viewController.addChild(viewController)

        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        container.view.addSubview(viewController.view)

        container.view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor).isActive = true
        container.view.rightAnchor.constraint(equalTo: viewController.view.rightAnchor).isActive = true
        container.view.topAnchor.constraint(equalTo: viewController.view.topAnchor).isActive = true
        container.view.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor).isActive = true

        viewController.didMove(toParent: container.viewController)
        completion?()
    }

    func registerPeek<T>(from sourceView: UIView, transitionGenerator: @escaping () -> Transition<T>, completion: Completion) {
        let delegate = CoordinatorPreviewingDelegateObject(transition: transitionGenerator, coordinator: AnyCoordinator(self), completion: completion)
        sourceView.strongReferences.append(delegate)
        
        navigationController.registerForPreviewing(with: delegate, sourceView: sourceView)
    }

    func push(_ viewController: UIViewController, with options: TransitionOptions, animation: Animation?, completion: Completion) {
        viewController.transitioningDelegate = animation
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        navigationController.pushViewController(viewController, animated: options.animated)
        CATransaction.commit()
    }

    func pop(with options: TransitionOptions, toRoot: Bool, animation: Animation?, completion: Completion) {
        let currentVC = navigationController.visibleViewController
        currentVC?.transitioningDelegate = animation
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        if toRoot {
            navigationController.popToRootViewController(animated: options.animated)
        } else {
            navigationController.popViewController(animated: options.animated)
        }
        CATransaction.commit()
    }

    // MARK: Helpers

    public func performTransition<T>(_ transition: Transition<T>, with options: TransitionOptions, completion: Completion = nil) {
        switch transition.type {
        case let transitionType as TransitionTypeVC:
            switch transitionType {
            case .bump(let presentable):
                presentable.presented(from: self)
                bump(completion: completion)
            case .presentAlert(let presentable):
                presentable.presented(from: self)
                presentAlert(presentable.viewController, with: options, completion: completion)
            case .present(let presentable):
                presentable.presented(from: self)
                present(presentable.viewController, with: options, animation: transition.animation, completion: completion)
            case .embed(let presentable, let container):
                presentable.presented(from: self)
                embed(presentable.viewController, in: container, with: options, completion: completion)
            case .embedIndex(let presentable, let container, let index):
                presentable.presented(from: self)
                embed(presentable.viewController, in: container, to: index, with: options, completion: completion)
            case .registerPeek(let source, let transitionGenerator):
                registerPeek(from: source.view, transitionGenerator: transitionGenerator, completion: completion)
            case .dismiss:
                dismiss(with: options, animation: transition.animation, completion: completion)
            case .none:
                bump(completion: completion)
            }
        case let transitionType as TransitionTypeNC:
            switch transitionType {
            case .bump(let presentable):
                presentable.presented(from: self)
                bump(completion: completion)
            case .presentAlert(let presentable):
                presentable.presented(from: self)
                presentAlert(presentable.viewController, with: options, completion: completion)
            case .push(let presentable):
                presentable.presented(from: self)
                push(presentable.viewController, with: options, animation: transition.animation, completion: completion)
            case .present(let presentable):
                presentable.presented(from: self)
                present(presentable.viewController, with: options, animation: transition.animation, completion: completion) 
            case .embed(let presentable, let container):
                presentable.presented(from: self)
                embed(presentable.viewController, in: container, with: options, completion: completion)
            case .embedIndex(let presentable, let container, let index):
                presentable.presented(from: self)
                embed(presentable.viewController, in: container, to: index, with: options, completion: completion)
            case .registerPeek(let source, let transitionGenerator):
                registerPeek(from: source.view, transitionGenerator: transitionGenerator, completion: completion)
            case .pop:
                pop(with: options, toRoot: false, animation: transition.animation, completion: completion)
            case .popToRoot:
                pop(with: options, toRoot: true, animation: transition.animation, completion: completion)
            case .dismiss:
                dismiss(with: options, animation: transition.animation, completion: completion)
            case .none:
                bump(completion: completion)
            }
        default:
            bump(completion: completion)
        }
    }

    private func presentationObservable(for viewController: UIViewController) -> Observable<Void> {
        return viewController.rx.sentMessage(#selector(UIViewController.viewDidAppear(_:)))
            .map { _ in () }
            .take(1)
    }

    private func dismissalObservable(for viewController: UIViewController) -> Observable<Void> {
        return viewController.rx.sentMessage(#selector(UIViewController.viewWillDisappear))
            .filter { _ in viewController.isBeingDismissed }
            .map { _ in () }
            .take(1)
    }
}
