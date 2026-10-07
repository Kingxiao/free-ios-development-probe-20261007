import XCTest

final class FreeIOSProbeUITests: XCTestCase {
    func testCounterInteraction() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()

        let counter = app.staticTexts["counter"]
        XCTAssertTrue(counter.waitForExistence(timeout: 10))
        XCTAssertEqual(counter.label, "0")
        app.buttons["increment"].tap()
        XCTAssertEqual(counter.label, "1")
        app.buttons["increment"].tap()
        XCTAssertEqual(counter.label, "2")

        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Native app after two taps"
        screenshot.lifetime = .keepAlways
        add(screenshot)

        app.buttons["reset"].tap()
        XCTAssertEqual(counter.label, "0")
    }
}
