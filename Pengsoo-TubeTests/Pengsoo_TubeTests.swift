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
    var errorOccurred = false
    
    override func setUp() {
        sut = HomeViewModel()
        sut.delegate = self
        errorOccurred = false
    }

    override func tearDown() {
        sut = nil
        HTTPStubs.removeAllStubs()
    }
    
    func testRequestPengsooTVList() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            let stubPath = OHPathForFile("pengsooList_page1.json", type(of: self))!

            return HTTPStubsResponse(
                fileAtPath: stubPath,
                statusCode: 200,
                headers: [ "Content-Type": "application/json; charset=UTF-8"]
            )
        }
        sut.getPengsooTvList()
        waitForThreeSeconds()
        XCTAssertGreaterThan(self.sut.listItems.count, 0)
    }
    
    func testRequestPengsooTVListNext() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            let stubPath = OHPathForFile("pengsooList_page1.json", type(of: self))!

            return HTTPStubsResponse(
                fileAtPath: stubPath,
                statusCode: 200,
                headers: [ "Content-Type": "application/json; charset=UTF-8"]
            )
        }
        
        stub(condition: isHost("www.googleapis.com") && containsQueryParams(["pageToken" : "CDIQAA"])) { _ in
            let stubPath = OHPathForFile("pengsooList_page2.json", type(of: self))!

            return HTTPStubsResponse(
                fileAtPath: stubPath,
                statusCode: 200,
                headers: [ "Content-Type": "application/json; charset=UTF-8"]
            )
        }
        
        sut.getPengsooTvList()
        waitForThreeSeconds()
        XCTAssertGreaterThan(self.sut.listItems.count, 0)
        
        sut.getPengsooTvList(isInitial:false)
        waitForThreeSeconds()
        XCTAssertGreaterThan(self.sut.listItems.count, 50)
    }
    
    func testRequestPengsooListTVLast() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            let stubPath = OHPathForFile("pengsooList_page1.json", type(of: self))!

            return HTTPStubsResponse(
                fileAtPath: stubPath,
                statusCode: 200,
                headers: [ "Content-Type": "application/json; charset=UTF-8"]
            )
        }
        
        stub(condition: isHost("www.googleapis.com") && containsQueryParams(["pageToken" : "CDIQAA"])) { _ in
            let stubPath = OHPathForFile("pengsooList_page2.json", type(of: self))!

            return HTTPStubsResponse(
                fileAtPath: stubPath,
                statusCode: 200,
                headers: [ "Content-Type": "application/json; charset=UTF-8"]
            )
        }
        
        stub(condition: isHost("www.googleapis.com") && containsQueryParams(["pageToken" : "CDIQAF"])) { _ in
            let stubPath = OHPathForFile("pengsooList_page3.json", type(of: self))!

            return HTTPStubsResponse(
                fileAtPath: stubPath,
                statusCode: 200,
                headers: [ "Content-Type": "application/json; charset=UTF-8"]
            )
        }
        
        sut.getPengsooTvList()
        waitForThreeSeconds()
        XCTAssertGreaterThan(self.sut.listItems.count, 0)
        
        sut.getPengsooTvList(isInitial:false)
        waitForThreeSeconds()
        XCTAssertGreaterThan(self.sut.listItems.count, 50)
        let itemList:[YoutubeItemModel] = Array(sut.listItems)
        
        sut.getPengsooTvList(isInitial:false)
        waitForThreeSeconds()
        XCTAssertEqual(itemList.count, sut.listItems.count)
    }
    
    func testRequestPengsooTVError() {
        stub(condition: isHost("www.googleapis.com")) { _ in
            return HTTPStubsResponse(error: NSError(domain: "Error", code: 400, userInfo: [:]))
        }
        
        sut.getPengsooTvList()
        waitForThreeSeconds()
        XCTAssertEqual(sut.listItems.count, 0)
        XCTAssertTrue(errorOccurred)
    }
    
    
    func waitForThreeSeconds() {
        expectation = XCTestExpectation(description: "wait until the request completed")
        wait(for: [expectation!], timeout: 3)
    }
}

extension Pengsoo_TubeTests: ViewModelDelegate {
    func reloadTable() {
        expectation!.fulfill()
    }
    
    func showError(error: ViewModelDelegateError) {
        expectation!.fulfill()
        errorOccurred = true
    }
}
