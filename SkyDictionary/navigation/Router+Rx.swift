//
//  Router+Rx.swift
//  SkyDictionary
//
//  Created by Никита Черников on 02/02/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import RxSwift

extension Reactive where Base: Router {
    
    func push(_ drawable: Drawable, isAnimated: Bool) -> Observable<Void> {
        return Observable.create { [weak base] observer -> Disposable in
            guard let base = base else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            base.push(drawable, isAnimated: true, onNavigateBack: {
                observer.onNext(())
                observer.onCompleted()
            })
            
            return Disposables.create()
        }
    }
    
}
