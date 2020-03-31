//
//  PlayerViewModelTests.swift
//  Pengsoo-TubeTests
//
//  Created by Yejun Park on 31/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

@testable import Peng_Ha_Tube
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
        let playItem = PlayItemModel(videoId: item.snippet.resourceId.videoId,
                                     videoTitle: item.snippet.title,
                                     videoDescription: item.snippet.description,
                                     thumbnailDefault: item.snippet.thumbnails.small.url,
                                     thumbnailMedium: item.snippet.thumbnails.medium.url,
                                     thumbnailHigh: item.snippet.thumbnails.high.url,
                                     publishedAt: item.snippet.publishedAt)
        
        sut.addToRecent(item: playItem)
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let libraryViewModel = LibraryViewModel()
        libraryViewModel.getRecent()
        
        XCTAssertEqual(libraryViewModel.recentItems.first?.videoId, playItem.videoId)
    }

    func testAddToRecentDuplication() {
        let homeViewModel = HomeViewModel()
        homeViewModel.dispatchPengsooList(type: .pengsooTv)
        _ = XCTWaiter.wait(for: [expectation(description: "Test after 3 seconds")], timeout: 3.0)
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let items = homeViewModel.getItemsList(for: .pengsooTv)
        let item = items![0]
        let playItem = PlayItemModel(videoId: item.snippet.resourceId.videoId,
                                     videoTitle: item.snippet.title,
                                     videoDescription: item.snippet.description,
                                     thumbnailDefault: item.snippet.thumbnails.small.url,
                                     thumbnailMedium: item.snippet.thumbnails.medium.url,
                                     thumbnailHigh: item.snippet.thumbnails.high.url,
                                     publishedAt: item.snippet.publishedAt)
        
        sut.addToRecent(item: playItem)
        
        let libraryViewModel = LibraryViewModel()
        libraryViewModel.getRecent()
        let recentItemsCount = libraryViewModel.recentItems.count
        
        sut.addToRecent(item: playItem)
        sut.addToRecent(item: playItem)
        sut.addToRecent(item: playItem)
        sut.addToRecent(item: playItem)
        
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
            let playItem = PlayItemModel(videoId: item.snippet.resourceId.videoId,
                                         videoTitle: item.snippet.title,
                                         videoDescription: item.snippet.description,
                                         thumbnailDefault: item.snippet.thumbnails.small.url,
                                         thumbnailMedium: item.snippet.thumbnails.medium.url,
                                         thumbnailHigh: item.snippet.thumbnails.high.url,
                                         publishedAt: item.snippet.publishedAt)
            
            sut.addToRecent(item: playItem)
            XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        }
        
        let libraryViewModel = LibraryViewModel()
        libraryViewModel.getRecent()
        for (index, item) in items!.reversed().enumerated() {
            XCTAssertEqual(item.snippet.resourceId.videoId, libraryViewModel.recentItems[index].videoId)
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