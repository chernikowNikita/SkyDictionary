//
//  AppCoordinator.swift
//  SkyDictionary
//
//  Created by Никита Черников on 02/02/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import UIKit
import RxSwift

class AppCoordinator: BaseCoordinator {
    
    let window: UIWindow
    let disposeBag = DisposeBag()
    
    init(window: UIWindow) {
        self.window = window
        super.init()
    }
    
    override func start() -> Observable<Void> {
        let navigationController = UINavigationController()
        let router = Router(navigationController: navigationController)
        let searchCoordinator = SearchCoordinator(router: router)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        return self.coordinate(searchCoordinator)
    }
}
