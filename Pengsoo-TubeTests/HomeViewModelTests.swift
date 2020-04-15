//
//  Pengsoo_TubeTests.swift
//  Pengsoo-TubeTests
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

@testable import PENG_HA__Tube
import OHHTTPStubs
import XCTest

class HomeViewModelTests: XCTestCase {
    
    var sut: HomeViewModel!
    var delegate: ViewModelDelegate!

    var expectation: XCTestExpectation?
    var errorOccurred: ViewModelDelegateError = .noError
    
    override func setUp() {
        sut = HomeViewModel()
        sut.delegate = self
        errorOccurred = .noError
    }

    override func tearDown() {
        sut = nil
        HTTPStubs.removeAllStubs()
        expectation = nil
    }
    
    func testNoInternetConnection() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
            return HTTPStubsResponse(error:notConnectedError)
        }

        sut.dispatchPengsooList(type: .pengsooOutside)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.networkError)
    }
    
    func testRequestPengsooTVList() {
//        stub(condition: isHost("www.googleapis.com")) { _ in
//            let stubPath = OHPathForFile("pengsooList_page1.json", type(of: self))!
//
//            return HTTPStubsResponse(
//                fileAtPath: stubPath,
//                statusCode: 200,
//                headers: [ "Content-Type": "application/json; charset=UTF-8"]
//            )
//        }
        sut.dispatchPengsooList(type: .pengsooTv)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }
    
    func testRequestPengsooTVListNext() {
        sut.dispatchPengsooList(type: .pengsooTv)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)

        sut.dispatchPengsooList(type: .pengsooTv, isInitial:false)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }

    func testRequestPengsooTVError() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            return HTTPStubsResponse(error: NSError(domain: "Error", code: 400, userInfo: [:]))
        }

        sut.dispatchPengsooList(type: .pengsooTv)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.networkError)
    }
    
    func testRequestPengsooYoutubeList() {
        sut.dispatchPengsooList(type: .pengsooYoutube)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }
    
    func testRequestPengsooYoutubeListNext() {
        sut.dispatchPengsooList(type: .pengsooYoutube)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)

        sut.dispatchPengsooList(type: .pengsooYoutube, isInitial:false)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }

    func testRequestPengsooYoutubeError() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            return HTTPStubsResponse(error: NSError(domain: "Error", code: 400, userInfo: [:]))
        }

        sut.dispatchPengsooList(type: .pengsooYoutube)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.networkError)
    }
    
    func testRequestPengsooOutsideList() {
        sut.dispatchPengsooList(type: .pengsooOutside)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }
    
    func testRequestPengsooOutsideListNext() {
        sut.dispatchPengsooList(type: .pengsooOutside)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)

        sut.dispatchPengsooList(type: .pengsooOutside, isInitial:false)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }

    func testRequestPengsooOutsideError() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            return HTTPStubsResponse(error: NSError(domain: "Error", code: 400, userInfo: [:]))
        }

        sut.dispatchPengsooList(type: .pengsooOutside)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.networkError)
    }
    
    func testGetItemsListForRequestType() {
        let tvListItems = sut.getItemsList(for: .pengsooTv)
        XCTAssertEqual(tvListItems, sut.tvListItems)
        
        let youtubeListItems = sut.getItemsList(for: .pengsooYoutube)
        XCTAssertEqual(youtubeListItems, sut.youtubeListItems)
        
        let outsideListItems = sut.getItemsList(for: .pengsooOutside)
        XCTAssertEqual(outsideListItems, sut.outsideListItems)
    }
    
    func testGetPlaylistItems() {
        let items = sut.getPlaylistItems()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let libraryViewModel = LibraryViewModel()
        libraryViewModel.getPlaylist()
        
        XCTAssertEqual(items, libraryViewModel.playlistItems)
    }
    
    func testAddtoNewPlaylist() {
        let items = sut.getPlaylistItems()
        
        stub(condition: isHost("www.googleapis.com")) { _ in
            let stubPath = OHPathForFile("pengsooList_page1.json", type(of: self))!

            return HTTPStubsResponse(
                fileAtPath: stubPath,
                statusCode: 200,
                headers: [ "Content-Type": "application/json; charset=UTF-8"]
            )
        }
        
        sut.dispatchPengsooList(type: .pengsooTv)
        waitForThreeSeconds()
        sut.addtoNewPlaylist(title: "test playlist1", at: 0, listOf: .pengsooTv)
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let mypageViewModel = LibraryViewModel()
        mypageViewModel.getPlaylist()
        
        XCTAssertEqual(items!.count + 1, mypageViewModel.playlistItems.count)
        
        let playlistItem = mypageViewModel.playlistItems.first!
        let libraryDetailViewModel = LibraryDetailViewModel(playItems: playlistItem.videos, title: playlistItem.title)
        libraryDetailViewModel.deletePlaylist()
    }
    
    func testAddToPlayList() {
        sut.dispatchPengsooList(type: .pengsooTv)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let libraryViewModel = LibraryViewModel()
        libraryViewModel.createPlaylist(title: "test_playlist1")
        
        sut.addToPlaylist(at: 0, listOf: .pengsooTv, toPlaylist: libraryViewModel.playlistItems.first!)
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        libraryViewModel.getPlaylist()
        let playlistItem = libraryViewModel.playlistItems.first!
        XCTAssertEqual(playlistItem.videos.count, 1)
        
        let libraryDetailViewModel = LibraryDetailViewModel(playItems: playlistItem.videos, title: playlistItem.title)
        libraryDetailViewModel.deletePlaylist()
    }
    
    func waitForThreeSeconds() {
        expectation = XCTestExpectation(description: "wait until the request completed")
        wait(for: [expectation!], timeout: 3)
    }
}

extension HomeViewModelTests: ViewModelDelegate {
    func success(type: RequestType, message: String) {
        if expectation != nil {
            expectation!.fulfill()
        }
        errorOccurred = .noError
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        if expectation != nil {
            expectation!.fulfill()
        }
        errorOccurred = error
    }
}
