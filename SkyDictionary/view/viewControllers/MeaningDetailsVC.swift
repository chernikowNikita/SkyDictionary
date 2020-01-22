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
import RxDataSources
import Action

class MeaningDetailsVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    // MARK: - Public properties
    var viewModel: MeaningDetailsVM!
    
    // MARK: - Private properties
    private var wordDetailsView: TextDetailsView!
    private var meaningDetailsView: TextDetailsView!
    private var difficultyDetailsView: TextDetailsView!
    private var imagesCV: UICollectionView!
    private var imagesDataSource: RxCollectionViewSectionedReloadDataSource<ImageSection>!
    private var errorView: ErrorView!
    private let disposeBag = DisposeBag()
    
    // MARK: - Create
    public static func Create(viewModel: MeaningDetailsVM) -> MeaningDetailsVC {
        let vc = R.Storyboard.main.instantiateViewController(withIdentifier: String(describing: self)) as! MeaningDetailsVC
        vc.viewModel = viewModel
        return vc
    }
    
    // MARK: - Life cycle
    override func loadView() {
        super.loadView()
        let wordDetailsView = TextDetailsView.Create()
        let meaningDetailsView = TextDetailsView.Create()
        let difficultyDetailsView = TextDetailsView.Create()
        let imagesCV = ImagesCollectionView.Create(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
        let errorView = ErrorView.Create()
        
        stackView.addArrangedSubview(wordDetailsView)
        stackView.addArrangedSubview(meaningDetailsView)
        stackView.addArrangedSubview(difficultyDetailsView)
        stackView.addArrangedSubview(imagesCV)
        stackView.addArrangedSubview(errorView)
        
        self.wordDetailsView = wordDetailsView
        self.meaningDetailsView = meaningDetailsView
        self.difficultyDetailsView = difficultyDetailsView
        self.imagesCV = imagesCV
        self.errorView = errorView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        configureImagesDataSource()
        
        bindViewModel()
        
        viewModel.load.onNext(())
    }
    
    // MARK: - Setup View
    private func setupView() {
        wordDetailsView.titleLabel.text = "Слово"
        meaningDetailsView.titleLabel.text = "Значение"
        difficultyDetailsView.titleLabel.text = "Сложность"
        
        wordDetailsView.isHidden = true
        meaningDetailsView.isHidden = true
        difficultyDetailsView.isHidden = true
        errorView.isHidden = true
        
        difficultyDetailsView.detailsLabel.isHidden = true
        difficultyDetailsView.detailsSoundBtn.isHidden = true
        
        ImageCell.registerWithNib(in: imagesCV)
    }
    
    private func configureImagesDataSource() {
        imagesDataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { dataSource, collectionView, indexPath, item in
            let cell = ImageCell.deque(for: collectionView, indexPath: indexPath)
            if let url = URL(string: item) {
                cell.imageView.kf.setImage(with: url)
            }
            return cell
        })
    }
    
    private func animate() {
        if !UIAccessibility.isReduceMotionEnabled {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            })
        }
    }
    
}

extension MeaningDetailsVC {
    
    func bindViewModel() {
        viewModel.loading
            .bind(to: loadingView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        bindWord(wordDetailsView)
        bindMeaning(meaningDetailsView)
        bindDifficultyDetails()
        bindImages()
        bindError()
        
        viewModel.loaded
            .subscribe(onNext: { [weak self] _ in
                self?.animate()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindWord(_ detailsView: TextDetailsView) {
        viewModel.meaningLoaded
            .map { _ in false }
            .bind(to: detailsView.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.text
            .bind(to: detailsView.textLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.transcription
            .map { $0 == nil }
            .bind(to: detailsView.detailsLabel.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.transcription
            .bind(to: detailsView.detailsLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.wordSoundUrl
            .map { $0 == nil }
            .bind(to: detailsView.detailsSoundBtn.rx.isHidden)
            .disposed(by: disposeBag)
        detailsView.detailsSoundBtn.rx.tap
            .bind(to: viewModel.listenWord)
            .disposed(by: disposeBag)
    }
    
    private func bindMeaning(_ detailsView: TextDetailsView) {
        viewModel.meaningLoaded
            .map { _ in false }
            .bind(to: detailsView.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.translation
            .bind(to: detailsView.textLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.definition
            .map { $0 == nil }
            .bind(to: detailsView.detailsLabel.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.definition
            .bind(to: detailsView.detailsLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.definitionSoundUrl
            .map { $0 == nil }
            .bind(to: detailsView.detailsSoundBtn.rx.isHidden)
            .disposed(by: disposeBag)
        detailsView.detailsSoundBtn.rx.tap
            .bind(to: viewModel.listenDefinition)
            .disposed(by: disposeBag)
    }
    
    private func bindDifficultyDetails() {
        viewModel.difficultyLevel
            .map { $0 == nil }
            .bind(to: difficultyDetailsView.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.difficultyLevel
            .unwrap()
            .map { String.init(repeating: "💪", count: $0) }
            .bind(to: difficultyDetailsView.textLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func bindImages() {
        viewModel.images
            .bind(to: imagesCV.rx.items(dataSource: imagesDataSource))
            .disposed(by: disposeBag)
    }
    
    private func bindError() {
        viewModel.error
            .map { !$0 }
            .bind(to: errorView.rx.isHidden)
            .disposed(by: disposeBag)
        errorView.retryBtn.rx.tap
            .bind(to: viewModel.load)
            .disposed(by: disposeBag)
    }
    
}
