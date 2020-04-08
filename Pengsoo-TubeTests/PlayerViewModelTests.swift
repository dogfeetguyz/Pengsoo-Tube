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
    
    func testPlayQueueWithItems() {
        let homeViewModel = HomeViewModel()
        homeViewModel.dispatchPengsooList(type: .pengsooTv)
        _ = XCTWaiter.wait(for: [expectation(description: "Test after 3 seconds")], timeout: 3.0)
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let items = homeViewModel.getItemsList(for: .pengsooTv)
        let playingIndex = 0
        sut.replaceQueue(videoItems: items!, playingIndex: playingIndex, requestType: .pengsooTv)
        
        XCTAssertEqual(items!.count, sut.getQueueItems().count)
        XCTAssertEqual(items![playingIndex].videoId, sut.getPlayingItem()?.videoId)
        XCTAssertEqual(playingIndex, sut.getPlayingIndex())
    }
    
    func testRequestMore() {
        let homeViewModel = HomeViewModel()
        homeViewModel.dispatchPengsooList(type: .pengsooTv)
        _ = XCTWaiter.wait(for: [expectation(description: "Test after 3 seconds")], timeout: 3.0)
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let items = homeViewModel.getItemsList(for: .pengsooTv)
        sut.replaceQueue(videoItems: items!, playingIndex: items!.count-1, requestType: .pengsooTv)
        let oldQueueCount = sut.getQueueItems().count
        
        homeViewModel.dispatchPengsooList(type: .pengsooTv, isInitial: false)
        _ = XCTWaiter.wait(for: [expectation(description: "Test after 3 seconds")], timeout: 3.0)
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let update_items = homeViewModel.getItemsList(for: .pengsooTv)
        sut.updateQueue(canRequestMore: true, videoItems: update_items!)
        
        XCTAssertEqual(update_items!.count > items!.count, true)
        XCTAssertEqual(sut.getQueueItems().count > oldQueueCount, true)
        XCTAssertEqual(update_items!.count, sut.getQueueItems().count)
    }
    
    func testRequestMoreNotAllowed() {
        let homeViewModel = HomeViewModel()
        homeViewModel.dispatchPengsooList(type: .pengsooTv)
        _ = XCTWaiter.wait(for: [expectation(description: "Test after 3 seconds")], timeout: 3.0)
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let items = homeViewModel.getItemsList(for: .pengsooTv)
        sut.replaceQueue(videoItems: items!, playingIndex: items!.count-1, requestType: .pengsooTv)
        let oldQueueCount = sut.getQueueItems().count
        
        sut.updateQueue(canRequestMore: false)
        
        XCTAssertEqual(sut.getQueueItems().count, oldQueueCount)
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
