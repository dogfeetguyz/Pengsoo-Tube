//
//  Pengsoo_TubeTests.swift
//  Pengsoo-TubeTests
//
//  Created by Yejun Park on 23/3/20.
//  Copyright © 2020 Yejun Park. All rights reserved.
//

@testable import Pengsoo_Tube
import OHHTTPStubs
import XCTest

class Pengsoo_TubeTests: XCTestCase {
    
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
    }
    
    func testNoInternetConnection() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
            return HTTPStubsResponse(error:notConnectedError)
        }

        sut.getPengsooList(type: .pengsooOutside)
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
        sut.getPengsooList(type: .pengsooTv)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }
    
    func testRequestPengsooTVListNext() {
        sut.getPengsooList(type: .pengsooTv)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)

        sut.getPengsooList(type: .pengsooTv, isInitial:false)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }

    func testRequestPengsooTVError() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            return HTTPStubsResponse(error: NSError(domain: "Error", code: 400, userInfo: [:]))
        }

        sut.getPengsooList(type: .pengsooTv)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.networkError)
    }
    
    func testRequestPengsooYoutubeList() {
        sut.getPengsooList(type: .pengsooYoutube)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }
    
    func testRequestPengsooYoutubeListNext() {
        sut.getPengsooList(type: .pengsooYoutube)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)

        sut.getPengsooList(type: .pengsooYoutube, isInitial:false)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }

    func testRequestPengsooYoutubeError() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            return HTTPStubsResponse(error: NSError(domain: "Error", code: 400, userInfo: [:]))
        }

        sut.getPengsooList(type: .pengsooYoutube)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.networkError)
    }
    
    func testRequestPengsooOutsideList() {
        sut.getPengsooList(type: .pengsooOutside)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }
    
    func testRequestPengsooOutsideListNext() {
        sut.getPengsooList(type: .pengsooOutside)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)

        sut.getPengsooList(type: .pengsooOutside, isInitial:false)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }

    func testRequestPengsooOutsideError() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            return HTTPStubsResponse(error: NSError(domain: "Error", code: 400, userInfo: [:]))
        }

        sut.getPengsooList(type: .pengsooOutside)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.networkError)
    }
    
    func testRequestHeader() {
        sut.getHeaderInfo()
        waitForThreeSeconds()
        XCTAssertGreaterThan(sut.headerUrl.count, 0)
    }
    
    func testAddToMyList() {
        sut.getPengsooList(type: .pengsooTv)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        let mypageViewModel = MypageViewModel()
        mypageViewModel.createPlaylist(title: "test_playlist1")
        
        sut.addToMylist(at: 0, listOf: .pengsooTv, toMylist: mypageViewModel.mylistItems.last!)
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        
        mypageViewModel.getMylist()
        XCTAssertEqual(mypageViewModel.mylistItems.last!.videos?.count, 1)
        
        mypageViewModel.deletePlaylist(at: mypageViewModel.mylistItems.count-1)
    }
    
    func waitForThreeSeconds() {
        expectation = XCTestExpectation(description: "wait until the request completed")
        wait(for: [expectation!], timeout: 3)
    }
}

extension Pengsoo_TubeTests: ViewModelDelegate {
    func reloadTable(type: RequestType) {
        expectation!.fulfill()
        errorOccurred = .noError
    }
    
    func reloadHeader() {
        expectation!.fulfill()
        errorOccurred = .noError
    }
    
    func success(message: String) {
        // local call -> no waiting time needed
        errorOccurred = .noError
    }
    
    func showError(type: RequestType, error: ViewModelDelegateError, message: String) {
        expectation!.fulfill()
        errorOccurred = error
    }
}
