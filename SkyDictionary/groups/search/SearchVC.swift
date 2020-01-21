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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var firstPageLoadingView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextPageLoadingView: UIActivityIndicatorView!
    
    // MARK: - Public properties
    var viewModel: SearchVM!
    
    // MARK: - Private properties
    private var errorView = ErrorView.Create(autoLayout: false)
    private let disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedReloadDataSource<SearchResultSection>!
    
    // MARK: - Create
    public static func Create(viewModel: SearchVM) -> SearchVC {
        let vc = R.Storyboard.main.instantiateViewController(withIdentifier: String(describing: self)) as! SearchVC
        vc.viewModel = viewModel
        return vc
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        configureDataSource()
        
        bindViewModel()
    }
    
    // MARK: - Private methods
    private func setupView() {
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).font = UIFont.boldSystemFont(ofSize: 17)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
        searchBar.backgroundImage = UIImage()
    }
   
    private func configureDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource(
          configureCell: { dataSource, tableView, indexPath, item in
            let cell = MeaningCell.deque(for: tableView, indexPath: indexPath)
            if let previewLink = item.previewUrl,
                let previewUrl = URL(string: previewLink) {
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
            .do(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .map { [weak self] indexPath in
                try? self?.dataSource.model(at: indexPath) as? Meaning
            }
            .unwrap()
            .map { $0.id }
            .subscribe(onNext: { [weak self] meaningId in
                let vm = MeaningDetailsVM(meaningId: meaningId)
                self?.open(scene: .meaningDetails(vm), with: .push)
            })
            .disposed(by: disposeBag)
        viewModel.searchResults
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        searchBar.searchTextField.rx.text
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
        viewModel.error
            .subscribe(onNext: { [weak self] error in
                guard let strongSelf = self else { return }
                if error {
                    strongSelf.tableView.tableFooterView = strongSelf.errorView
                } else {
                    strongSelf.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                }
            })
            .disposed(by: disposeBag)
        errorView.retryBtn.rx.tap
            .bind(to: viewModel.retry)
            .disposed(by: disposeBag)
       
    }
    
}

