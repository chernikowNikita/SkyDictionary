//
//  Scene+ViewController.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import UIKit

extension Scene {
    
    func viewController(for type: SceneTransitionType) -> UIViewController {
        switch self {
        case .search(let viewModel):
            let vc = SearchVC.Create(viewModel: viewModel)
            return wrapInNcIfNeeded(vc, for: type)
        case .meaningDetails(let viewModel):
            let vc = MeaningDetailsVC.Create(viewModel: viewModel)
            return wrapInNcIfNeeded(vc, for: type)
        }
    }
    
    fileprivate func wrapInNcIfNeeded(_ vc: UIViewController, for type: SceneTransitionType) -> UIViewController {
        switch type {
        case .push:
            return vc
        case .modal(inNavigationController: let needToWrapInNC):
            if needToWrapInNC {
                return wrapInNC(vc)
            }
            return vc
        }
    }
    
    fileprivate func wrapInNC(_ vc: UIViewController) -> UIViewController {
        let nc = UINavigationController()
        nc.setViewControllers([vc], animated: true)
        return nc
    }
    
}
