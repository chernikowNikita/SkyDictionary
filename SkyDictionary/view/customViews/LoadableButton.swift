//
//  LoadableButton.swift
//  SkyDictionary
//
//  Created by Никита Черников on 19/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Action

class LoadableButton: UIButton {
    
    // MARK: - Private properties
    private let loadingView = UIActivityIndicatorView(style: .medium)
    private let disposeBag = DisposeBag()
    
    
    private var loading: Observable<Bool>? {
        return self.rx.action?.enabled
            .map { !$0 }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLoading()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLoading()
    }
    
    // MARK: - Private methods
    private func setupLoading() {
        addSubview(loadingView)
        loadingView.hidesWhenStopped = true
        loadingView.backgroundColor = .systemBackground
        loadingView.alpha = 1
        loadingView.stopAnimating()
        loadingView.centerInSuperView()
        
        self.loading?
            .bind(to: loadingView.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
    
}
