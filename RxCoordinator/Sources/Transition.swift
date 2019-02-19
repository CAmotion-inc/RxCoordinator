//
//  Transition.swift
//  RxCoordinator
//
//  Created by Stefan Kofler on 30.04.18.
//  Copyright © 2018 Stefan Kofler. All rights reserved.
//

import Foundation
import UIKit

public protocol TransitionType {}

public enum TransitionTypeVC: TransitionType {
    case bump(Presentable)
    case presentAlert(Presentable)
    case present(Presentable)
    case embed(presentable: Presentable, container: Container)
    case embedIndex(presentable: Presentable, container: Container, index: Int)
    case registerPeek(source: Container, transitionGenerator: () -> ViewTransition)
    case dismiss
    case none
}

public enum TransitionTypeNC: TransitionType {
    case bump(Presentable)
    case presentAlert(Presentable)
    case push(Presentable)
    case present(Presentable)
    case embed(presentable: Presentable, container: Container)
    case embedIndex(presentable: Presentable, container: Container, index: Int)
    case registerPeek(source: Container, transitionGenerator: () -> NavigationTransition)
    case pop
    case popToRoot
    case dismiss
    case none
}

public struct Transition<RootType: TransitionType> {
    internal let type: RootType
    internal let animation: Animation?
}

public typealias ViewTransition = Transition<TransitionTypeVC>
public typealias NavigationTransition = Transition<TransitionTypeNC>

extension Transition where RootType == TransitionTypeVC {

    public static func bump(_ presentable: Presentable) -> Transition {
        return Transition(type: .bump(presentable), animation: nil)
    }

    public static func presentAlert(_ presentable: Presentable) -> Transition {
        return Transition(type: .presentAlert(presentable), animation: nil)
    }

    public static func present(_ presentable: Presentable, animation: Animation? = nil) -> Transition {
        return Transition(type: .present(presentable), animation: animation)
    }

    public static func embed(_ presentable: Presentable, in container: Container, to index: Int? = nil) -> Transition {
        return index != nil ?
            Transition(type: .embedIndex(presentable: presentable, container: container, index: index!), animation: nil) :
            Transition(type: .embed(presentable: presentable, container: container), animation: nil)
    }

    public static func registerPeek<R: Route>(from source: Container, route: R, coordinator: AnyCoordinator<R>) -> Transition where R.RootType == TransitionTypeVC {
        return Transition(type: .registerPeek(source: source, transitionGenerator: {
            route.prepareTransition(coordinator: coordinator)
        }), animation: nil)
    }

    public static func dismiss(animation: Animation? = nil) -> Transition {
        return Transition(type: .dismiss, animation: animation)
    }

    public static func none() -> Transition {
        return Transition(type: .none, animation: nil)
    }

}

extension Transition where RootType == TransitionTypeNC {

    public static func bump(_ presentable: Presentable) -> Transition {
        return Transition(type: .bump(presentable), animation: nil)
    }

    public static func presentAlert(_ presentable: Presentable) -> Transition {
        return Transition(type: .presentAlert(presentable), animation: nil)
    }

    public static func present(_ presentable: Presentable, animation: Animation? = nil) -> Transition {
        return Transition(type: .present(presentable), animation: animation)
    }

    public static func embed(_ presentable: Presentable, in container: Container, to index: Int? = nil) -> Transition {
        return index != nil ?
            Transition(type: .embedIndex(presentable: presentable, container: container, index: index!), animation: nil) :
            Transition(type: .embed(presentable: presentable, container: container), animation: nil)
    }

    public static func registerPeek<R: Route>(from source: Container, route: R, coordinator: AnyCoordinator<R>) -> Transition where R.RootType == TransitionTypeNC {
        return Transition(type: .registerPeek(source: source, transitionGenerator: {
            route.prepareTransition(coordinator: coordinator)
        }), animation: nil)
    }

    public static func dismiss(animation: Animation? = nil) -> Transition {
        return Transition(type: .dismiss, animation: animation)
    }

    public static func none() -> Transition {
        return Transition(type: .none, animation: nil)
    }

    public static func push(_ presentable: Presentable, animation: Animation? = nil) -> Transition {
        return Transition(type: .push(presentable), animation: animation)
    }

    public static func pop(animation: Animation? = nil) -> Transition {
        return Transition(type: .pop, animation: animation)
    }

    public static func popToRoot(animation: Animation? = nil) -> Transition {
        return Transition(type: .popToRoot, animation: animation)
    }

}
