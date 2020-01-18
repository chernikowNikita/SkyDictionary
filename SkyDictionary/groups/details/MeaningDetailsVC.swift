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
        stackView.addArrangedSubview(wordDetailsView)
        stackView.addArrangedSubview(meaningDetailsView)
        stackView.addArrangedSubview(difficultyDetailsView)
        self.wordDetailsView = wordDetailsView
        self.meaningDetailsView = meaningDetailsView
        self.difficultyDetailsView = difficultyDetailsView
        difficultyDetailsView.detailsStackView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        configureDataSource()
        
        setEditing(true, animated: false)
        
    }
    
    // MARK: - Setup View
    private func setupView() {
        wordDetailsView.titleLabel.text = "Слово"
        meaningDetailsView.titleLabel.text = "Значение"
        difficultyDetailsView.titleLabel.text = "Сложность"
        difficultyDetailsView.isHidden = true
    }
    
    private func configureDataSource() {
        
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
        
        bindTextDetails(with: sharedMeaning)
        bindMeaningDetails(with: sharedMeaning)
        bindDifficultyDetails(with: sharedMeaning)
        
        sharedMeaning
            .subscribe(onNext: { [weak self] _ in
                self?.animate()
            })
            .disposed(by: disposeBag)
            
        viewModel.loadMeaningAction.inputs.onNext(())
    }
    
    private func bindTextDetails(with sharedMeaning: Observable<MeaningDetails>) {
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
            .bind(to: wordDetailsView.detailsSound.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func bindMeaningDetails(with sharedMeaning: Observable<MeaningDetails>) {
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
            .bind(to: meaningDetailsView.detailsSound.rx.isHidden)
            .disposed(by: disposeBag)
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
