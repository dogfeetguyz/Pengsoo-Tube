//
//  MypageViewModelTests.swift
//  Pengsoo-TubeTests
//
//  Created by Yejun Park on 25/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

@testable import Peng_Ha_Tube
import XCTest

class LibraryViewModelTests: XCTestCase {
    
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

    func testCreatePlaylist() {
        sut.getPlaylist()
        
        let title = "playlist1"
        let oldListCount = sut.playlistItems.count
        sut.createPlaylist(title: title)
        
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertGreaterThan(sut.playlistItems.count, oldListCount)
        XCTAssertEqual(sut.playlistItems.last?.title, title)
        
        sut.deletePlaylist(at: oldListCount)
    }
    
    func testDeletePlaylist() {
        sut.getPlaylist()
        
        let title = "test_playlist1"
        sut.createPlaylist(title: title)
        let newListCount = sut.playlistItems.count

        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        sut.deletePlaylist(at: newListCount-1)

        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertGreaterThan(newListCount, sut.playlistItems.count)
    }
    
    func testUpdatePlaylist() {
        sut.getPlaylist()
        
        let title = "test_playlist1"
        let oldListCount = sut.playlistItems.count
        sut.createPlaylist(title: title)

        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let newTitle = "new test_playlist1"
        sut.updatePlaylist(at: oldListCount, newTitle: newTitle)
        
        XCTAssertEqual(sut.playlistItems.last?.title, newTitle)
        
        sut.deletePlaylist(at: oldListCount)
    }
    
    func testLoadPlaylist() {
        sut.getPlaylist()
        XCTAssertNotEqual(errorOccurred, ViewModelDelegateError.fail)
        XCTAssertNotNil(sut.playlistItems)
    }
    
    func testLoadRecent() {
        sut.getRecent()
        XCTAssertNotEqual(errorOccurred, ViewModelDelegateError.fail)
        XCTAssertNotNil(sut.recentItems)
    }
}

extension LibraryViewModelTests: ViewModelDelegate {
    func success(type: RequestType, message: String) {
        errorOccurred = .noError
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        errorOccurred = error
    }
}

