//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by D. K. on 10.08.24.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        let poster = app.images["Poster"]
        XCTAssertTrue(poster.waitForExistence(timeout: 5))
        
        let firstPosterData = poster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in
                poster.screenshot().pngRepresentation != firstPosterData
            },
            object: nil
        )
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed, "Изображение не изменилось после нажатия кнопки Yes")
    }
    
    func testNoButton() {
        let poster = app.images["Poster"]
        XCTAssertTrue(poster.waitForExistence(timeout: 5))
        
        let firstPosterData = poster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in
                poster.screenshot().pngRepresentation != firstPosterData
            },
            object: nil
        )
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(result, .completed, "Изображение не изменилось после нажатия кнопки No")
        
        let counterLabel = app.staticTexts["CounterLabel"]
        XCTAssertTrue(counterLabel.waitForExistence(timeout: 5))
        XCTAssertEqual(counterLabel.label, "2/10", "Счетчик вопросов не обновился до 2/10")
    }
    
    func testGameFinish() {
        for _ in 1...10 {
            let yesButton = app.buttons["Yes"]
            XCTAssertTrue(yesButton.waitForExistence(timeout: 5))
            yesButton.tap()
        }

        let alert = app.alerts.element
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }

    func testAlertDismiss() {
        for _ in 1...10 {
            let yesButton = app.buttons["Yes"]
            XCTAssertTrue(yesButton.waitForExistence(timeout: 5))
            yesButton.tap()
        }
        
        let alert = app.alerts.element
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.buttons.firstMatch.tap()
        
        let counterLabel = app.staticTexts["CounterLabel"]
        XCTAssertTrue(counterLabel.waitForExistence(timeout: 5))
        XCTAssertFalse(alert.exists)
        XCTAssertEqual(counterLabel.label, "1/10")
    }
}
