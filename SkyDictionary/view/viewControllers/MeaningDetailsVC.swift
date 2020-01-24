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
    
    // MARK: - Private properties
    var viewModel: MeaningDetailsVM!
    private var wordDetailView: DetailView!
    private var meaningDetailView: DetailView!
    private var difficultyDetailView: DetailView!
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
        let wordDetailView = DetailView.Create()
        let meaningDetailView = DetailView.Create()
        let difficultyDetailView = DetailView.Create()
        let imagesCV = ImagesCollectionView.Create(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
        let errorView = ErrorView.Create(autolayout: true)
        
        stackView.addArrangedSubview(wordDetailView)
        stackView.addArrangedSubview(meaningDetailView)
        stackView.addArrangedSubview(difficultyDetailView)
        stackView.addArrangedSubview(imagesCV)
        stackView.addArrangedSubview(errorView)
        
        self.wordDetailView = wordDetailView
        self.meaningDetailView = meaningDetailView
        self.difficultyDetailView = difficultyDetailView
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
        wordDetailView.titleLabel.text = "Слово"
        meaningDetailView.titleLabel.text = "Значение"
        difficultyDetailView.titleLabel.text = "Сложность"
        
        wordDetailView.isHidden = true
        meaningDetailView.isHidden = true
        difficultyDetailView.isHidden = true
        errorView.isHidden = true
        
        difficultyDetailView.detailLabel.isHidden = true
        difficultyDetailView.detailListenBtn.isHidden = true
        
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
        // Проверяем включено ли на устройстве "Уменьшение движения"
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
        
        bindWord(wordDetailView)
        bindMeaning(meaningDetailView)
        bindDifficultyLevel(difficultyDetailView)
        bindImages()
        bindError()
        
        viewModel.loaded
            .subscribe(onNext: { [weak self] _ in
                self?.animate()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindWord(_ detailView: DetailView) {
        viewModel.meaningLoaded
            .map { _ in false }
            .bind(to: detailView.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.text
            .bind(to: detailView.textLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.transcription
            .map { $0 == nil }
            .bind(to: detailView.detailLabel.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.transcription
            .bind(to: detailView.detailLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.wordSoundUrl
            .map { $0 == nil }
            .bind(to: detailView.detailListenBtn.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.wordSoundUrl
            .unwrap()
            .subscribe(onNext: { [weak self] url in
                self?.bindDetailListen(url: url, for: detailView)
            })
            .disposed(by: disposeBag)

    }
    
    private func bindMeaning(_ detailView: DetailView) {
        viewModel.meaningLoaded
            .map { _ in false }
            .bind(to: detailView.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.translation
            .bind(to: detailView.textLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.definition
            .map { $0 == nil }
            .bind(to: detailView.detailLabel.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.definition
            .bind(to: detailView.detailLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.definitionSoundUrl
            .map { $0 == nil }
            .bind(to: detailView.detailListenBtn.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.definitionSoundUrl
            .unwrap()
            .subscribe(onNext: { [weak self] url in
                self?.bindDetailListen(url: url, for: detailView)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindDetailListen(url: URL, for detailView: DetailView) {
        detailView.detailListenBtn.rx.action = viewModel.prepareListenAction(for: url)
        detailView.detailListenBtn.setupAction()
    }
    
    private func bindDifficultyLevel(_ detailView: DetailView) {
        viewModel.difficultyLevel
            .map { $0 == nil }
            .bind(to: detailView.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.difficultyLevel
            .unwrap()
            .map { String.init(repeating: "💪", count: $0) }
            .bind(to: detailView.textLabel.rx.text)
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
