//
//  PlayerViewModelTests.swift
//  Pengsoo-TubeTests
//
//  Created by Yejun Park on 31/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

@testable import PENG_HA__Tube
import XCTest

class PlayerViewModelTests: XCTestCase {
    
    var sut: PlayerViewModel!
    var delegate: ViewModelDelegate!

    var errorOccurred: ViewModelDelegateError = .noError
    
    override func setUpWithError() throws {
        sut = PlayerViewModel()
        sut.delegate = self
        errorOccurred = .noError
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testAddToRecent() {
        let homeViewModel = HomeViewModel()
        homeViewModel.dispatchPengsooList(type: .pengsooTv)
        _ = XCTWaiter.wait(for: [expectation(description: "Test after 3 seconds")], timeout: 3.0)
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)

        let items = homeViewModel.getItemsList(for: .pengsooTv)
        let item = items![0]
        
        sut.addToRecent(item: item)
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let libraryViewModel = LibraryViewModel()
        libraryViewModel.getRecent()
        
        XCTAssertEqual(libraryViewModel.recentItems.first?.videoId, item.videoId)
    }

    func testAddToRecentDuplication() {
        let homeViewModel = HomeViewModel()
        homeViewModel.dispatchPengsooList(type: .pengsooTv)
        _ = XCTWaiter.wait(for: [expectation(description: "Test after 3 seconds")], timeout: 3.0)
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let items = homeViewModel.getItemsList(for: .pengsooTv)
        let item = items![0]
        
        sut.addToRecent(item: item)
        
        let libraryViewModel = LibraryViewModel()
        libraryViewModel.getRecent()
        let recentItemsCount = libraryViewModel.recentItems.count
        
        sut.addToRecent(item: item)
        sut.addToRecent(item: item)
        sut.addToRecent(item: item)
        sut.addToRecent(item: item)
        
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        libraryViewModel.getRecent()
        XCTAssertEqual(recentItemsCount, libraryViewModel.recentItems.count)
    }
    
    func testRecentOrder() {
        let homeViewModel = HomeViewModel()
        homeViewModel.dispatchPengsooList(type: .pengsooTv)
        _ = XCTWaiter.wait(for: [expectation(description: "Test after 3 seconds")], timeout: 3.0)
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)

        let items = homeViewModel.getItemsList(for: .pengsooTv)
        for item in items! {
            sut.addToRecent(item: item)
            XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        }
        
        let libraryViewModel = LibraryViewModel()
        libraryViewModel.getRecent()
        for (index, item) in items!.reversed().enumerated() {
            XCTAssertEqual(item.videoId, libraryViewModel.recentItems[index].videoId)
        }
    }
}

extension PlayerViewModelTests: ViewModelDelegate {
    func success(type: RequestType, message: String) {
        errorOccurred = .noError
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        errorOccurred = error
    }
}
