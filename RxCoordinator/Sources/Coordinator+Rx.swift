//
//  Coordinator+Rx.swift
//  Action
//
//  Created by Tomoki Takahashi on 2019/01/30.
//

import Foundation
import RxSwift

extension Coordinator {
    public var rx: Reactive<Self> {
        return Reactive(self)
    }
}

extension Reactive where Base: Coordinator {
    public func transition(to route: Base.CoordinatorRoute) -> Observable<Void> {
        return transition(to: route, with: TransitionOptions.defaultOptions)
    }
    
    public func transition(to route: Base.CoordinatorRoute, with options: TransitionOptions) -> Observable<Void> {
        let transition = route.prepareTransition(coordinator: AnyCoordinator(base))
        return Observable.create { [weak base] observer in
            guard let base = base else {
                observer.onCompleted()
                return Disposables.create()
            }
            base.performTransition(transition, with: options) {
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
