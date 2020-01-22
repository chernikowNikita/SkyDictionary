//
//  Scene+ViewController.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import UIKit

extension Scene {
    
    func viewController() -> UIViewController {
        switch self {
        case .search(let viewModel):
            let vc = SearchVC.Create(viewModel: viewModel)
            return vc
        case .meaningDetails(let viewModel):
            let vc = MeaningDetailsVC.Create(viewModel: viewModel)
            return vc
        }
    }
    
}
