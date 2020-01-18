//
//  MeaningDetailsVC.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MeaningDetailsVC: UIViewController {
    
    // MARK: - Public properties
    var viewModel: MeaningDetailsVM!
    
    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    
    // MARK: - Create
    public static func Create(viewModel: MeaningDetailsVM) -> MeaningDetailsVC {
        var vc = R.Storyboard.main.instantiateViewController(withIdentifier: String(describing: self)) as! MeaningDetailsVC
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

extension MeaningDetailsVC: BindableType {
    
    func bindViewModel() {
        let sharedMeaning = viewModel.loadMeaningAction.elements.share(replay: 1)
        sharedMeaning
            .map { $0.text }
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        viewModel.loadMeaningAction.inputs.onNext(())
    }
    
}
