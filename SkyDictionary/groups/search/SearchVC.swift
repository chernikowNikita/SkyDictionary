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
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Public properties
    var viewModel: SearchVM!
    
    // MARK: - Private properties
    let disposeBag = DisposeBag()
    
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
        searchField.rx.text
            .filter { $0 != nil }
            .map { $0! }
            .distinctUntilChanged()
            .filter { $0.count > 1 }
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
    }
    
}

