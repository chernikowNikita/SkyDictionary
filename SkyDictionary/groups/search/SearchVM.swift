//
//  SearchVM.swift
//  SkyDictionary
//
//  Created by Никита Черников on 14/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import RxSwift
import RxCocoa
import Action
import Moya
import RxDataSources
import RxSwiftExt

typealias SearchResultSection = SectionModel<String, Meaning>

class SearchVM {
    
    // MARK: - Public properties
    // MARK: - Input
    let query: PublishSubject<String> = PublishSubject<String>()
    let page: BehaviorSubject<Int> = BehaviorSubject<Int>(value: 1)
    let nextPage: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    // MARK: - Output
    let searchResults: BehaviorSubject<[SearchResultSection]> = BehaviorSubject<[SearchResultSection]>(value: [])
    let loadingState: BehaviorSubject<LoadingState> = BehaviorSubject<LoadingState>(value: .notLoading)
    
    // MARK: - Private properties
    private lazy var searchAction: Action<QueryData, SearchResultsData> = { this in
        return Action<QueryData, SearchResultsData>() { queryData in
            let query = queryData.query
            let page = queryData.page
            
            print("action initiated")
            
            let isFirstPage = page == 1
            this.loadingState.onNext(.loading(firstPage: isFirstPage))
            return SkyMoyaProvider.shared.rx
                .request(.search(query: query, page: page, pageSize: PAGE_SIZE))
                .filterSuccessfulStatusCodes()
                .map([SearchResult].self)
                .catchErrorJustReturn([])
                .map { SearchResultsData(isFirstPage: isFirstPage, results: $0) }
                .asObservable()
        }
    }(self)
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init() {
        let sharedResults = searchAction.elements.share(replay: 1)
        
        sharedResults
            .map { _ in LoadingState.notLoading }
            .bind(to: loadingState)
            .disposed(by: disposeBag)
        
        sharedResults
            .scan([]) { array, newData -> [SearchResult] in
                if newData.isFirstPage {
                    return newData.results
                }
                return array + newData.results
            }
            .map { results -> [SearchResultSection] in
                return results.map { result in
                    return SearchResultSection(model: result.text, items: result.meanings)
                }
            }
            .bind(to: searchResults)
            .disposed(by: disposeBag)
        
        page
            .withLatestFrom(query) { page, query in
                return QueryData(query: query, page: page)
            }
            .filter { $0.isNeedToSearch }
            .bind(to: searchAction.inputs)
            .disposed(by: disposeBag)
        
        nextPage
            .withLatestFrom(page)
            .withLatestFrom(searchResults) { page, results -> Int? in
                return results.count / PAGE_SIZE == page ? page : nil
            }
            .unwrap()
            .map { $0 + 1 }
            .debug()
            .bind(to: page)
            .disposed(by: disposeBag)
        
        query
            .map { _ in return 1 }
            .bind(to: page)
            .disposed(by: disposeBag)
        
    }
}
