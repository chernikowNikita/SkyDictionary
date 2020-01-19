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
import RxDataSources
import Kingfisher

class SearchVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var firstPageLoadingView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextPageLoadingView: UIActivityIndicatorView!
    
    // MARK: - Public properties
    var viewModel: SearchVM!
    
    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SearchResultSection>!
    
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
        
        self.viewModel = SearchVM()
        bindViewModel()
        
        setEditing(true, animated: false)
    }
    
    // MARK: - Setup View
    private func setupView() {
        
    }
    
    // MARK: - Private properties
    private func configureDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource(
          configureCell: { dataSource, tableView, indexPath, item in
            let cell = MeaningCell.deque(for: tableView, indexPath: indexPath)
            if let previewLink = item.previewUrl,
                let previewUrl = URL(string: previewLink.httpsPrefixed) {
                cell.previewImageView.kf.setImage(with: previewUrl)
            }
            cell.translationLabel.text = item.translation?.text
            return cell
          },
          titleForHeaderInSection: { dataSource, index in
            if index >= dataSource.sectionModels.count {
                return nil
            }
            return dataSource.sectionModels[index].model
          }
        )
    }
    
}

extension SearchVC: BindableType {
    
    func bindViewModel() {
        tableView.rx.itemSelected
            .map { [weak self] indexPath in
                try? self?.dataSource.model(at: indexPath) as? Meaning
            }
            .unwrap()
            .subscribe(onNext: { [weak self] meaning in
                let vm = MeaningDetailsVM(meaningId: meaning.id)
                let vc = Scene.meaningDetails(vm).viewController(for: .push)
                self?.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        viewModel.searchResults
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        searchField.rx.text
            .unwrap()
            .distinctUntilChanged()
            .filter { $0.count > 1 }
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        
        let startLoadingOffset: CGFloat = 200.0
        tableView.rx.contentOffset
            .map { offset in
                return offset.y + self.tableView.frame.size.height + startLoadingOffset > self.tableView.contentSize.height
            }
            .distinctUntilChanged()
            .debug()
            .filter { $0 }
            .bind(to: viewModel.nextPage)
            .disposed(by: disposeBag)
        
        viewModel.loadingState
            .map { state in
                switch state {
                case .loading(firstPage: let isFirst):
                    return isFirst
                case .notLoading:
                    return false
                }
            }
            .bind(to: firstPageLoadingView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.loadingState
            .map { state in
                switch state {
                case .loading(firstPage: let isFirst):
                    return !isFirst
                case .notLoading:
                    return false
                }
            }
            .bind(to: nextPageLoadingView.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
}

