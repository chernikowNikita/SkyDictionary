//
//  SearchVC.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchVC: UIViewController {
    
    // MARK: - Public properties
    var viewModel: SearchVM!
    
    // MARK: - Private properties
    
    
    // MARK: - Create
    public static func Create(viewModel: SearchVM) -> SearchVC {
        var vc = R.Storyboard.main.instantiateViewController(withIdentifier: String(describing: self)) as! SearchVC
        vc.bindViewModel(to: viewModel)
        return vc
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        configureDataSource()
        
        setEditing(true, animated: false)
    }
    
    // MARK: - Setup View
    private func setupView() {
        
    }
    
    private func configureDataSource() {
        
    }
    
}

extension SearchVC: BindableType {
    
    func bindViewModel() {
        
    }
    
}

