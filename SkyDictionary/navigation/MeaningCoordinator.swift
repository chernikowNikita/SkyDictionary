//
//  MeaningCoordinator.swift
//  SkyDictionary
//
//  Created by Никита Черников on 02/02/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import RxSwift

class MeaningCoordinator: BaseCoordinator {
    
    let router: Router
    let meaningId: Int
    let disposeBag = DisposeBag()
    
    init(meaningId: Int, router: Router) {
        self.meaningId = meaningId
        self.router = router
    }
    
    override func start() -> Observable<Void> {
        let viewModel = MeaningDetailsVM(meaningId: meaningId, apiProvider: SkyMoyaProvider.shared)
        let viewController = MeaningDetailsVC.Create(viewModel: viewModel)
        
        return router.rx.push(viewController, isAnimated: true)
    }
    
}
