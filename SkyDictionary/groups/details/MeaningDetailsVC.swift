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

typealias ImageSection = SectionModel<String?, String>

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
    private var imagesCVHeightC: NSLayoutConstraint!
    private var imagesDataSource: RxCollectionViewSectionedReloadDataSource<ImageSection>!
    private let disposeBag = DisposeBag()
    
    // MARK: - Create
    public static func Create(viewModel: MeaningDetailsVM) -> MeaningDetailsVC {
        var vc = R.Storyboard.main.instantiateViewController(withIdentifier: String(describing: self)) as! MeaningDetailsVC
        vc.bindViewModel(to: viewModel)
        return vc
    }
    
    // MARK: - Life cycle
    override func loadView() {
        super.loadView()
        let wordDetailsView = TextDetailsView.Create()
        let meaningDetailsView = TextDetailsView.Create()
        let difficultyDetailsView = TextDetailsView.Create()
        let imagesCollectionView = prepareImagesCV()
        stackView.addArrangedSubview(wordDetailsView)
        stackView.addArrangedSubview(meaningDetailsView)
        stackView.addArrangedSubview(difficultyDetailsView)
        stackView.addArrangedSubview(imagesCollectionView)
        self.wordDetailsView = wordDetailsView
        self.meaningDetailsView = meaningDetailsView
        self.difficultyDetailsView = difficultyDetailsView
        self.imagesCV = imagesCollectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        configureImagesDataSource()
        
        setEditing(true, animated: false)
        
    }
    
    // MARK: - Setup View
    private func setupView() {
        wordDetailsView.titleLabel.text = "Слово"
        meaningDetailsView.titleLabel.text = "Значение"
        difficultyDetailsView.titleLabel.text = "Сложность"
        wordDetailsView.isHidden = true
        meaningDetailsView.isHidden = true
        difficultyDetailsView.isHidden = true
        difficultyDetailsView.detailsStackView.isHidden = true
    }
    
    private func prepareImagesCV() -> UICollectionView {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0)
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: IMAGE_SIZE, height: IMAGE_SIZE)
        flowLayout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let view = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        let constraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        view.addConstraint(constraint)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.allowsSelection = false
        view.isScrollEnabled = false
        view.backgroundColor = .white
        self.imagesCVHeightC = constraint
        return view
    }
    
    private func configureImagesDataSource() {
        ImageCell.register(in: imagesCV)
        imagesDataSource = RxCollectionViewSectionedReloadDataSource(configureCell: { dataSource, collectionView, indexPath, item in
            let cell = ImageCell.deque(for: collectionView, indexPath: indexPath)
            if let url = URL(string: item.httpsPrefixed) {
                cell.imageView.kf.setImage(with: url)
            }
            return cell
        })
    }
    
    private func animate() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
}

extension MeaningDetailsVC: BindableType {
    
    func bindViewModel() {
        viewModel.loadMeaningAction.enabled
            .map { !$0 }
            .bind(to: loadingView.rx.isAnimating)
            .disposed(by: disposeBag)
        let sharedMeaning = viewModel.loadMeaningAction.elements.share(replay: 1)
        sharedMeaning
            .map { $0.text }
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        bindWordDetails(with: sharedMeaning)
        bindMeaningDetails(with: sharedMeaning)
        bindDifficultyDetails(with: sharedMeaning)
        
        sharedMeaning
            .map { meaning in
                return meaning.images.map { $0.url }
            }
            .map { [ImageSection(model: nil, items: $0)] }
            .debug()
            .bind(to: imagesCV.rx.items(dataSource: imagesDataSource))
            .disposed(by: disposeBag)
        
        imagesCV.rx.observe(CGSize.self, "contentSize")
            .subscribe(onNext: { [weak self] size in
                guard let strongSelf = self,
                    let size = size else { return }
                strongSelf.imagesCVHeightC.constant = size.height
            })
            .disposed(by: disposeBag)
        
        sharedMeaning
            .subscribe(onNext: { [weak self] _ in
                self?.animate()
            })
            .disposed(by: disposeBag)
            
        viewModel.loadMeaningAction.inputs.onNext(())
    }
    
    private func bindWordDetails(with sharedMeaning: Observable<MeaningDetails>) {
        sharedMeaning
            .map { _ in false }
            .bind(to: wordDetailsView.rx.isHidden)
            .disposed(by: disposeBag)
        sharedMeaning
            .map { $0.text }
            .bind(to: wordDetailsView.textLabel.rx.text)
            .disposed(by: disposeBag)
        sharedMeaning
            .map { meaning in
                return meaning.soundUrl == nil && meaning.transcription == nil
            }
            .bind(to: wordDetailsView.detailsStackView.rx.isHidden)
            .disposed(by: disposeBag)
        sharedMeaning
            .map { $0.transcription }
            .bind(to: wordDetailsView.detailsLabel.rx.text)
            .disposed(by: disposeBag)
        sharedMeaning
            .map { meaning in
                return meaning.soundUrl == nil
            }
            .bind(to: wordDetailsView.detailsSoundBtn.rx.isHidden)
            .disposed(by: disposeBag)
        wordDetailsView.detailsSoundBtn.rx.action = CocoaAction() { [weak self] _ in
            guard let strongSelf = self else { return Observable.just(()) }
            return strongSelf.viewModel.play(type: .word)
        }
        wordDetailsView.detailsSoundBtn.setupAction()
    }
    
    private func bindMeaningDetails(with sharedMeaning: Observable<MeaningDetails>) {
        sharedMeaning
            .map { _ in false }
            .bind(to: meaningDetailsView.rx.isHidden)
            .disposed(by: disposeBag)
        sharedMeaning
            .map { meaning in
                var translation = meaning.translation?.text ?? ""
                if let note = meaning.translation?.note {
                    translation += " (\(note))"
                }
                return translation
            }
            .bind(to: meaningDetailsView.textLabel.rx.text)
            .disposed(by: disposeBag)
        sharedMeaning
            .map { meaning in
                return meaning.definition?.soundUrl == nil && meaning.definition?.text == nil
            }
            .bind(to: meaningDetailsView.detailsStackView.rx.isHidden)
            .disposed(by: disposeBag)
        sharedMeaning
            .map { $0.definition?.text }
            .bind(to: meaningDetailsView.detailsLabel.rx.text)
            .disposed(by: disposeBag)
        sharedMeaning
            .map { meaning in
                return meaning.definition?.soundUrl == nil
            }
            .bind(to: meaningDetailsView.detailsSoundBtn.rx.isHidden)
            .disposed(by: disposeBag)
        meaningDetailsView.detailsSoundBtn.rx.action = CocoaAction() { [weak self] _ in
            guard let strongSelf = self else { return Observable.just(()) }
            return strongSelf.viewModel.play(type: .meaning)
        }
        meaningDetailsView.detailsSoundBtn.setupAction()
    }
    
    private func bindDifficultyDetails(with sharedMeaning: Observable<MeaningDetails>) {
        sharedMeaning
            .map { meaning in
                return meaning.difficultyLevel == nil
            }
            .bind(to: difficultyDetailsView.rx.isHidden)
            .disposed(by: disposeBag)
        sharedMeaning
            .map { $0.difficultyLevel }
            .unwrap()
            .map { level in
                return String.init(repeating: "💪", count: level)
            }
            .bind(to: difficultyDetailsView.textLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
}
