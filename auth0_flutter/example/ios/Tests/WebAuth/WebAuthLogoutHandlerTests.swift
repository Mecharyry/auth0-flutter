import XCTest
import Auth0

@testable import auth0_flutter

class WebAuthLogoutHandlerTests: XCTestCase {
    let spy = SpyWebAuth(clientId: "foo", url: URL(string: "https://auth0.com")!, telemetry: Telemetry.init())
    var sut: WebAuthLogoutMethodHandler!

    override func setUpWithError() throws {
        sut = WebAuthLogoutMethodHandler(client: spy)
    }
}

// MARK: - Optional Arguments

extension WebAuthLogoutHandlerTests {

    // MARK: returnTo

    func testAddsReturnTo() {
        let returnTo = "https://auth0.com"
        sut.handle(with: ["returnTo":  returnTo]) { _ in }
        XCTAssertEqual(spy.redirectURLValue?.absoluteString, returnTo)
    }

    func testDoesNotAddReturnToWhenNil() {
        sut.handle(with: [:]) { _ in }
        XCTAssertNil(spy.redirectURLValue)
    }
}

// MARK: - Logout Result

extension WebAuthLogoutHandlerTests {
    func testCallsSDKLogoutMethod() {
        sut.handle(with: [:]) { _ in }
        XCTAssertTrue(spy.calledLogout)
    }

    func testProducesNilValue() {
        let expectation = self.expectation(description: "Produced nil value")
        spy.logoutResult = .success(())
        sut.handle(with: [:]) { result in
            XCTAssertNil(result)
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testProducesWebAuthError() {
        let errors: [String: WebAuthError] = ["USER_CANCELLED": .userCancelled, "UNKNOWN": .unknown]
        var expectations: [XCTestExpectation] = []
        for (code, error) in errors {
            let expectation = self.expectation(description: "Produced the WebAuth error \(code)")
            expectations.append(expectation)
            spy.logoutResult = .failure(error)
            sut.handle(with: [:]) { result in
                assertHas(webAuthError: error, code: code, result)
                expectation.fulfill()
            }
        }
        wait(for: expectations)
    }
}