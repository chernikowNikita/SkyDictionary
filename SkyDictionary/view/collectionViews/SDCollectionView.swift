//
//  SDCollectionView.swift
//  SkyDictionary
//
//  Created by Никита Черников on 22/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SDCollectionView: UICollectionView {
    private var heightConstraint: NSLayoutConstraint!
    private let disposeBag = DisposeBag()
    
    static func Create(frame: CGRect) -> SDCollectionView {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: IMAGE_SIZE, height: IMAGE_SIZE)
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return SDCollectionView(frame: frame, collectionViewLayout: flowLayout)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }
    
    private func setup() {
        let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        self.addConstraint(constraint)
        self.heightConstraint = constraint
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.allowsSelection = false
        self.isScrollEnabled = false
        self.backgroundColor = .systemBackground
        
        self.rx.observe(CGSize.self, "contentSize")
            .unwrap()
            .map { $0.height }
            .bind(to: heightConstraint.rx.constant)
            .disposed(by: disposeBag)
    }
}
