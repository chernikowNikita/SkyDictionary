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
    @IBOutlet weak var tableView: UITableView!
    
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
    
    private func configureDataSource() {
        dataSource = RxTableViewSectionedReloadDataSource(
          configureCell: { dataSource, tableView, indexPath, item in
            let cell = MeaningCell.deque(for: tableView, indexPath: indexPath)
            if let previewLink = item.previewUrl,
                let previewUrl = URL(string: "https:\(previewLink)") {
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
    
    static let startLoadingOffset: CGFloat = 20.0

    static func isNearTheBottomEdge(contentOffset: CGPoint, _ tableView: UITableView) -> Bool {
        return contentOffset.y + tableView.frame.size.height + startLoadingOffset > tableView.contentSize.height
    }
    
}

extension SearchVC: BindableType {
    
    func bindViewModel() {
        viewModel.searchResults
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        searchField.rx.text
            .filter { $0 != nil }
            .map { $0! }
            .distinctUntilChanged()
            .filter { $0.count > 1 }
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        tableView.rx.contentOffset
            .map { offset in
                return offset.y + self.tableView.frame.size.height + 20.0 > self.tableView.contentSize.height
            }
            .distinctUntilChanged()
            .debug()
            .filter { $0 }
            .bind(to: viewModel.nextPage)
            .disposed(by: disposeBag)
    }
    
}

