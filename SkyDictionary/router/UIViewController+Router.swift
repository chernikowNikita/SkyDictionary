//
//  UIViewController+Router.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func open(scene: Scene, with transitionType: SceneTransitionType) {
        let vc = scene.viewController(for: transitionType)
        switch transitionType {
        case .push:
            push(vc: vc)
        case .modal(inNavigationController: _):
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func push(vc: UIViewController) {
        if let nc = self as? UINavigationController {
            nc.pushViewController(vc, animated: true)
        } else if let nc = self.navigationController {
            nc.pushViewController(vc, animated: true)
        }
    }
    
}
