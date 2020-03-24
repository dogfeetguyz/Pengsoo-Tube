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

        sut.getPengsooTvList(type: .pengsooOutside)
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
        sut.getPengsooTvList(type: .pengsooTv)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }
    
    func testRequestPengsooTVListNext() {
        sut.getPengsooTvList(type: .pengsooTv)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)

        sut.getPengsooTvList(type: .pengsooTv, isInitial:false)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }

    func testRequestPengsooTVError() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            return HTTPStubsResponse(error: NSError(domain: "Error", code: 400, userInfo: [:]))
        }

        sut.getPengsooTvList(type: .pengsooTv)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.networkError)
    }
    
    func testRequestPengsooYoutubeList() {
        sut.getPengsooTvList(type: .pengsooYoutube)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }
    
    func testRequestPengsooYoutubeListNext() {
        sut.getPengsooTvList(type: .pengsooYoutube)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)

        sut.getPengsooTvList(type: .pengsooYoutube, isInitial:false)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }

    func testRequestPengsooYoutubeError() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            return HTTPStubsResponse(error: NSError(domain: "Error", code: 400, userInfo: [:]))
        }

        sut.getPengsooTvList(type: .pengsooYoutube)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.networkError)
    }
    
    func testRequestPengsooOutsideList() {
        sut.getPengsooTvList(type: .pengsooOutside)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }
    
    func testRequestPengsooOutsideListNext() {
        sut.getPengsooTvList(type: .pengsooOutside)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)

        sut.getPengsooTvList(type: .pengsooOutside, isInitial:false)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
    }

    func testRequestPengsooOutsideError() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            return HTTPStubsResponse(error: NSError(domain: "Error", code: 400, userInfo: [:]))
        }

        sut.getPengsooTvList(type: .pengsooOutside)
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.networkError)
    }
    
    func testRequestHeader() {
        sut.getHeaderInfo()
        waitForThreeSeconds()
        XCTAssertGreaterThan(sut.headerUrl.count, 0)
    }
    
    func waitForThreeSeconds() {
        expectation = XCTestExpectation(description: "wait until the request completed")
        wait(for: [expectation!], timeout: 3)
    }
}

extension Pengsoo_TubeTests: ViewModelDelegate {
    func reloadTable(type: HomeViewRequestType) {
        expectation!.fulfill()
        errorOccurred = .noError
    }
    
    func reloadHeader() {
        expectation!.fulfill()
        errorOccurred = .noError
    }
    
    func showError(type: HomeViewRequestType, error: ViewModelDelegateError) {
        expectation!.fulfill()
        errorOccurred = error
    }
}
