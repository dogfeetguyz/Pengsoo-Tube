//
//  MylistDetailViewModelTests.swift
//  Pengsoo-TubeTests
//
//  Created by Yejun Park on 25/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

@testable import Peng_Ha_Tube
import XCTest
import OHHTTPStubs

class PlaylistDetailViewModelTests: XCTestCase {
    
    var sut: LibraryDetailViewModel!
    var delegate: ViewModelDelegate!
    var mypageViewModel: LibraryViewModel!

    var errorOccurred: ViewModelDelegateError = .noError
    
    override func setUp() {
        mypageViewModel = LibraryViewModel()
        mypageViewModel.createPlaylist(title: "test_playlist1")
        
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
            homeViewModel.addToPlaylist(at: i, listOf: .pengsooTv, toPlaylist: mypageViewModel.playlistItems.last!)
        }
        mypageViewModel.getPlaylist()
        
        sut = LibraryDetailViewModel(playlistItem: mypageViewModel.playlistItems.last!)
        
        sut.delegate = self
        errorOccurred = .noError
    }

    override func tearDown() {
        sut = nil
        mypageViewModel.deletePlaylist(at: mypageViewModel.playlistItems.count-1)
        mypageViewModel = nil
        HTTPStubs.removeAllStubs()
    }

    func testDeleteItem() {
        let oldCount = sut.playlistItem.videos?.count ?? 0
        sut.deleteItem(at: 0)
        
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertEqual(oldCount - 1, sut.playlistItem.videos?.count)
    }
    
    func replaceItem() {
        let oldIndex = 0
        let newIndex = 3
        let idForOldIndex = (sut.playlistItem.videos?[oldIndex] as! MyVideo).videoId
        sut.moveItem(from: oldIndex, to: newIndex)
        
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertEqual(idForOldIndex, (sut.playlistItem.videos?[newIndex] as! MyVideo).videoId)
    }
}

extension PlaylistDetailViewModelTests: ViewModelDelegate {
    func success(type: RequestType, message: String) {
        errorOccurred = .noError
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        errorOccurred = error
    }
}
