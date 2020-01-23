//
//  MeaningDetailsVMTests.swift
//  SkyDictionaryTests
//
//  Created by Никита Черников on 20/01/2020.
//  Copyright © 2020 Никита Черников. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking

@testable import SkyDictionary

class MeaningDetailsVMTests: XCTestCase {
    
    var viewModel: MeaningDetailsVM!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        viewModel = MeaningDetailsVM(meaningId: 0, apiProvider: SkyMoyaProvider.sharedTest)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        viewModel = nil
        disposeBag = nil
    }

    func testError() {
        let expect = expectation(description: "error")
        var result: Bool!
        viewModel.error
            .subscribe(onNext: { e in
                result = e
                expect.fulfill()
            })
            .disposed(by: disposeBag)
        viewModel.load.onNext(())
        
        waitForExpectations(timeout: 1.0) { error in
            if let e = error {
                XCTFail(e.localizedDescription)
                return
            }
        }
        XCTAssertFalse(result)
    }
    
    func testText() {
        let expect = expectation(description: "text")
        var result: String!
        viewModel.text
            .subscribe(onNext: { text in
                result = text
                expect.fulfill()
            })
            .disposed(by: disposeBag)
        viewModel.load.onNext(())
        
        waitForExpectations(timeout: 1.0) { error in
            if let e = error {
                XCTFail(e.localizedDescription)
                return
            }
        }
        XCTAssertEqual(result, "test")
    }
    
    func testDifficultyLevel() {
        let expect = expectation(description: "difficultyLevel")
        var result: Int?
        viewModel.difficultyLevel
            .subscribe(onNext: { level in
                result = level
                expect.fulfill()
            })
            .disposed(by: disposeBag)
        viewModel.load.onNext(())
        
        waitForExpectations(timeout: 1.0) { error in
            if let e = error {
                XCTFail(e.localizedDescription)
                return
            }
        }
        XCTAssert(result == 4)
    }

    

}
