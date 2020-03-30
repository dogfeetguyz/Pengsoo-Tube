//
//  MypageViewModelTests.swift
//  Pengsoo-TubeTests
//
//  Created by Yejun Park on 25/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

@testable import Peng_Ha_Tube
import XCTest

class MypageViewModelTests: XCTestCase {
    
    var sut: LibraryViewModel!
    var delegate: ViewModelDelegate!

    var errorOccurred: ViewModelDelegateError = .noError
    
    override func setUp() {
        sut = LibraryViewModel()
        sut.delegate = self
        errorOccurred = .noError
    }

    override func tearDown() {
        sut = nil
    }

    func testCreateMylist() {
        let title = "playlist1"
        let oldListCount = sut.mylistItems.count
        sut.createPlaylist(title: title)
        
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertGreaterThan(sut.mylistItems.count, oldListCount)
        XCTAssertEqual(sut.mylistItems.last?.title, title)
        
        sut.deletePlaylist(at: oldListCount)
    }
    
    func testDeleteMylist() {
        let title = "test_playlist1"
        sut.createPlaylist(title: title)
        let newListCount = sut.mylistItems.count

        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        sut.deletePlaylist(at: newListCount-1)

        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertGreaterThan(newListCount, sut.mylistItems.count)
    }
    
    func testUpdateMylist() {
        let title = "test_playlist1"
        let oldListCount = sut.mylistItems.count
        sut.createPlaylist(title: title)

        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let newTitle = "new test_playlist1"
        sut.updatePlaylist(at: oldListCount, newTitle: newTitle)
        
        XCTAssertEqual(sut.mylistItems.last?.title, newTitle)
        
        sut.deletePlaylist(at: oldListCount)
    }
    
    func testLoadMylist() {
        let oldListCount = sut.mylistItems.count
        let random = Int.random(in: Range(5 ... 10))
        for i in 0 ..< random {
            sut.createPlaylist(title: "test_playlist\(i)")
            XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        }
        
        sut.getMylist()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertEqual(oldListCount + random, sut.mylistItems.count)
        
        for _ in Range(0 ... random) {
            sut.deletePlaylist(at: oldListCount)
        }
    }
}

extension MypageViewModelTests: ViewModelDelegate {
    func success(type: RequestType, message: String) {
        errorOccurred = .noError
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        errorOccurred = error
    }
}

