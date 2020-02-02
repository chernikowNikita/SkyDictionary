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
    
    // MARK: - Input
    let query: PublishSubject<String> = PublishSubject() // текст поиска
    let nextPage: PublishSubject<Bool> = PublishSubject() // сигнал о необходимости загрузить следующую страницу
    let retry: PublishSubject<Void> = PublishSubject() // сигнал о необходимости повторить запрос
    
    // MARK: - Output
    let searchResults: BehaviorSubject<[SearchResultSection]> = BehaviorSubject<[SearchResultSection]>(value: [])
    let loading: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
    let error: BehaviorSubject<Bool> = BehaviorSubject<Bool>(value: false)
    
    // MARK: - Input&Output
    let didSelect: PublishSubject<Meaning> = PublishSubject()
    
    // MARK: - Private properties
    private let page: BehaviorSubject<Int> = BehaviorSubject<Int>(value: 1)
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init() {
        let sharedSearch: Observable<QueryData> = page
            .withLatestFrom(query) { page, query in
                return QueryData(query: query, page: page)
            }
            .filter { $0.isNeedToSearch }
            .share(replay: 1)
        
        sharedSearch
            .map { _ in true }
            .bind(to: loading)
            .disposed(by: disposeBag)
        
        // При поиске нового слова очищаем результаты старого поиска
        sharedSearch
            .filter { $0.isFirstPage }
            .map { _ -> [SearchResultSection] in return [] }
            .bind(to: searchResults)
            .disposed(by: disposeBag)
        
        let sharedResults: Observable<SearchResultsData?> = sharedSearch
            .flatMapLatest { queryData -> Observable<SearchResultsData?> in
                return SkyMoyaProvider.shared.rx
                    .request(.search(query: queryData.query, page: queryData.page, pageSize: PAGE_SIZE))
                    .map([SearchResult].self)
                    .map { SearchResultsData(isFirstPage: queryData.isFirstPage, results: $0) }
                    .catchErrorJustReturn(nil)
                    .asObservable()
            }
            .share(replay: 1)
        
        sharedResults
            .map { _ in false }
            .bind(to: loading)
            .disposed(by: disposeBag)
        
        sharedResults
            .unwrap()
            // Собираем предыдущие страницы с новой
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
        
        sharedResults
            .map { results in
                return results == nil
            }
            .bind(to: error)
            .disposed(by: disposeBag)
        
        nextPage
            .withLatestFrom(page)
            // Проверка необходимости загрузки следующей страницы
            .withLatestFrom(searchResults) { page, results -> Int? in
                return results.count / PAGE_SIZE == page ? page : nil
            }
            .unwrap()
            .map { $0 + 1 }
            .bind(to: page)
            .disposed(by: disposeBag)
        
        retry
            .withLatestFrom(page)
            .bind(to: page)
            .disposed(by: disposeBag)
        
        query
            .distinctUntilChanged()
            .filter { $0.count > 1 }
            .map { _ in return 1 }
            .bind(to: page)
            .disposed(by: disposeBag)
        
    }
}
