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

class SplashViewModelTests: XCTestCase {
    
    var sut: SplashViewModel!
    var delegate: ViewModelDelegate!

    var expectation: XCTestExpectation?
    var errorOccurred: ViewModelDelegateError = .noError
    
    override func setUp() {
        sut = SplashViewModel()
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

        sut.dispatchHeaderInfo()
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.networkError)
    }
    
    func testRequestHeader() {
        sut.dispatchHeaderInfo()
        waitForThreeSeconds()
        XCTAssertEqual(errorOccurred, ViewModelDelegateError.noError)
        XCTAssertGreaterThan(HomeViewModel().getHeaderUrl()!.count, 0)
    }
    
    func waitForThreeSeconds() {
        expectation = XCTestExpectation(description: "wait until the request completed")
        wait(for: [expectation!], timeout: 3)
    }
}

extension SplashViewModelTests: ViewModelDelegate {
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
