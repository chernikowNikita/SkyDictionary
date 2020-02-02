//
//  BaseCoordinator.swift
//  SkyDictionary
//
//  Created by Никита Черников on 02/02/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import RxSwift

class BaseCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    func start() -> Observable<Void> {
        print("Start method should be implemented in inherited class.")
        return .never()
    }
    
    func coordinate(_ coordinator: Coordinator) -> Observable<Void> {
        self.store(coordinator: coordinator)
        return coordinator
            .start()
            .debug()
            .do(onNext: { [weak self, weak coordinator] _ in
                guard let strongSelf = self,
                    let coordinator = coordinator else { return }
                strongSelf.free(coordinator: coordinator)
            })
    }
    
}
