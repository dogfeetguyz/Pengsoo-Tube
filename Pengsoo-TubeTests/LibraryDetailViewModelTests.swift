//
//  MylistDetailViewModelTests.swift
//  Pengsoo-TubeTests
//
//  Created by Yejun Park on 25/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

@testable import PENG_HA__Tube
import XCTest
import OHHTTPStubs

class LibraryDetailViewModelTests: XCTestCase {
    
    var sut: LibraryDetailViewModel!
    var delegate: ViewModelDelegate!
    var libraryViewModel: LibraryViewModel!

    var errorOccurred: ViewModelDelegateError = .noError
    
    override func setUp() {
        errorOccurred = .noError
    }
    
    func setUpPlaylist() {
        libraryViewModel = LibraryViewModel()
        libraryViewModel.createPlaylist(title: "test_playlist1")
        
        stub(condition: isHost("www.googleapis.com")) { _ in
            let stubPath = OHPathForFile("pengsooList_page1.json", type(of: self))!

            return HTTPStubsResponse(
                fileAtPath: stubPath,
                statusCode: 200,
                headers: [ "Content-Type": "application/json; charset=UTF-8"]
            )
        }
        
        let homeViewModel = HomeViewModel()
        homeViewModel.dispatchPengsooList(type: .pengsooTv)
        
        _ = XCTWaiter.wait(for: [expectation(description: "Test after 1 seconds")], timeout: 1.0)
        for i in 0 ..< 5 {
            homeViewModel.addToPlaylist(at: i, listOf: .pengsooTv, toPlaylist: libraryViewModel.playlistItems.first!)
        }
        libraryViewModel.getPlaylist()
        
        let playlistItem = libraryViewModel.playlistItems.first!
        sut = LibraryDetailViewModel(playItems: playlistItem.videos, title: playlistItem.title)
        sut.delegate = self
    }
    
    func setUpRecent() {
        libraryViewModel = LibraryViewModel()
        
        stub(condition: isHost("www.googleapis.com")) { _ in
            let stubPath = OHPathForFile("pengsooList_page1.json", type(of: self))!

            return HTTPStubsResponse(
                fileAtPath: stubPath,
                statusCode: 200,
                headers: [ "Content-Type": "application/json; charset=UTF-8"]
            )
        }
        
        let homeViewModel = HomeViewModel()
        homeViewModel.dispatchPengsooList(type: .pengsooTv)
        _ = XCTWaiter.wait(for: [expectation(description: "Test after 1 seconds")], timeout: 1.0)
        
        for i in 0 ..< 5 {
            Util.openPlayer(videoItems: homeViewModel.tvListItems, playingIndex: i, requestType: .pengsooTv)
            _ = XCTWaiter.wait(for: [expectation(description: "Test after 0.3 seconds")], timeout: 0.3)
        }
        
        libraryViewModel.getRecent()
        sut = LibraryDetailViewModel(playItems: libraryViewModel.recentItems, title: "Recent")
        sut.delegate = self
    }

    override func tearDown() {
        libraryViewModel = nil
        sut.deletePlaylist()
        sut = nil
        HTTPStubs.removeAllStubs()
    }

    func testDeletePlaylistItem() {
        setUpPlaylist()
        
        let oldCount = sut.playItems.count
        sut.deleteItem(at: 0)
        
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertEqual(oldCount - 1, sut.playItems.count)
    }
    
    func testDeleteRecentItem() {
        setUpRecent()
        
        let oldCount = sut.playItems.count
        sut.deleteItem(at: 0)
        
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertEqual(oldCount - 1, sut.playItems.count)
    }
    
    func testClearPlaylistItems() {
        setUpPlaylist()
        sut.clearItems()
        
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertEqual(0, sut.playItems.count)
    }
    
    func testClearRecentItems() {
        setUpRecent()
        sut.clearItems()
        
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertEqual(0, sut.playItems.count)
    }
    
    func replaceItem() {
        setUpPlaylist()
        
        let oldIndex = 0
        let newIndex = 3
        let idForOldIndex = sut.playItems[oldIndex].videoId
        sut.moveItem(from: oldIndex, to: newIndex)
        
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertEqual(idForOldIndex, sut.playItems[newIndex].videoId)
    }
    
    func testDeletePlaylist() {
        setUpPlaylist()
        
        sut.deletePlaylist()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }
    
    func testUpdatePlaylist() {
        setUpPlaylist()
        
        let currentTitle = sut.title
        let newTitle = "new test_playlist1"
        sut.updatePlaylist(newTitle: newTitle)
        
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertNotEqual(sut.title, currentTitle)
        XCTAssertEqual(sut.title, newTitle)
    }
    
    func testUpdatePlaylistSameName() {
        setUpPlaylist()
        
        let currentTitle = sut.title
        sut.updatePlaylist(newTitle: currentTitle)
        
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.fail)
        XCTAssertEqual(sut.title, currentTitle)
    }
    
    func testUpdatePlaylistDuplicate() {
        setUpPlaylist()
        
        libraryViewModel.createPlaylist(title: "test_playlist2")
        
        let currentTitle = sut.title
        sut.updatePlaylist(newTitle: "test_playlist2")
        
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.fail)
        XCTAssertNotEqual(sut.title, "test_playlist2")
        XCTAssertEqual(sut.title, currentTitle)
        
        
        libraryViewModel.getPlaylist()
        let playlistItem = libraryViewModel.playlistItems.first!
        LibraryDetailViewModel(playItems: playlistItem.videos, title: playlistItem.title).deletePlaylist()
    }
}

extension LibraryDetailViewModelTests: ViewModelDelegate {
    func success(type: RequestType, message: String) {
        errorOccurred = .noError
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        errorOccurred = error
    }
}

