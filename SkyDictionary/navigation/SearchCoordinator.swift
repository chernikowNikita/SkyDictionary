//
//  SearchCoordinator.swift
//  SkyDictionary
//
//  Created by Никита Черников on 02/02/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import RxSwift

class SearchCoordinator: BaseCoordinator {
    
    let router: Router
    let disposeBag = DisposeBag()
    
    init(router: Router) {
        self.router = router
    }
    
    override func start() -> Observable<Void> {
        let viewModel = SearchVM()
        let viewController = SearchVC.Create(viewModel: viewModel)
        
        viewModel.didSelect
            .subscribe(onNext: { [weak self] meaning in
                self?.showMeaning(with: meaning.id)
            })
            .disposed(by: disposeBag)
        
        return router.rx.push(viewController, isAnimated: true)
    }
    
    private func showMeaning(with meaningId: Int) {
        let meaningCoordinator = MeaningCoordinator(meaningId: meaningId, router: router)
        self.coordinate(meaningCoordinator)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
