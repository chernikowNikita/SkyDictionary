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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    // MARK: - Private properties
    private var viewModel: SearchVM!
    private var errorView = ErrorView.Create(autolayout: false)
    private var dataSource: RxTableViewSectionedReloadDataSource<SearchResultSection>!
    private let disposeBag = DisposeBag()
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let _ = tableView.tableFooterView as? ErrorView {
            setTVFooterErrorView()
        } else {
            setTVFooterEmptyView()
        }
    }
    
    // MARK: - Private methods
    private func setupView() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.layoutIfNeeded()
        
        setTVFooterEmptyView()
        
        searchBar.backgroundImage = UIImage()
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
   
    private func configureDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource(
          configureCell: { dataSource, tableView, indexPath, item in
            let cell = ShortMeaningCell.deque(for: tableView, indexPath: indexPath)
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
    
    private func setTVFooterErrorView() {
        errorView.frame.size.height = 120
        tableView.tableFooterView = errorView
    }
    
    private func setTVFooterEmptyView() {
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
}

extension SearchVC {
    
    func bindViewModel() {
        tableView.rx.itemSelected
            .do(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .map { [weak self] indexPath in
                try? self?.dataSource.model(at: indexPath) as? ShortMeaning
            }
            .unwrap()
            .bind(to: viewModel.didSelect)
            .disposed(by: disposeBag)
        
        viewModel.searchResults
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        searchBar.searchTextField.rx.text
            .unwrap()
            .filter { $0.count > 1 }
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        // Пагинация, при достижении contentOffset START_LOADING_OFFSET посылаем во viewModel сигнал о необходимости загрузки следующей страницы
        tableView.rx.contentOffset
            .map { offset in
                return offset.y + self.tableView.frame.size.height + START_LOADING_OFFSET > self.tableView.contentSize.height
            }
            .distinctUntilChanged()
            .filter { $0 }
            .bind(to: viewModel.nextPage)
            .disposed(by: disposeBag)
        
        viewModel.loading
            .bind(to: loadingView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.error
            .subscribe(onNext: { [weak self] error in
                guard let strongSelf = self else { return }
                if error {
                    strongSelf.setTVFooterErrorView()
                } else {
                    strongSelf.setTVFooterEmptyView()
                }
            })
            .disposed(by: disposeBag)
        
        errorView.retryBtn.rx.tap
            .bind(to: viewModel.retry)
            .disposed(by: disposeBag)
       
    }
    
}

extension SearchVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        }
    }
    
}

