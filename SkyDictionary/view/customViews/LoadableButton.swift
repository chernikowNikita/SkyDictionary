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
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Public methods
    func setupAction() {
        self.rx.action?.enabled
            .map { !$0 }
            .bind(to: loadingView.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    private func setupView() {
        addSubview(loadingView)
        loadingView.hidesWhenStopped = true
        loadingView.backgroundColor = .systemBackground
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.color = self.tintColor
        loadingView.stopAnimating()
        loadingView.fillSuperView()
    }
    
    
}
