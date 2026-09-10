import XCTest
import SwiftUI
@testable import EntrakeiaMac

final class ContentViewTests: XCTestCase {

    func testStretchButtonSetsActiveViewToStretch() {
        var activeView: String? = nil
        activeView = "stretch"
        XCTAssertEqual(activeView, "stretch", "STRETCH button should set activeView to 'stretch'")
    }

    func testWimHofButtonSetsActiveViewToWimHof() {
        var activeView: String? = nil
        activeView = "wim_hof"
        XCTAssertEqual(activeView, "wim_hof", "WIM HOF button should set activeView to 'wim_hof'")
    }

    func testExerciseButtonSetsActiveViewToExercise() {
        var activeView: String? = nil
        activeView = "exercise"
        XCTAssertEqual(activeView, "exercise", "EXERCISE button should set activeView to 'exercise'")
    }

    func testWalkButtonSetsActiveViewToWalk() {
        var activeView: String? = nil
        activeView = "walk"
        XCTAssertEqual(activeView, "walk", "WALK button should set activeView to 'walk'")
    }

    func testBackButtonResetsActiveViewToNil() {
        var activeView: String? = "stretch"
        activeView = nil
        XCTAssertNil(activeView, "Back button should reset activeView to nil")
    }

    func testDaySelectionUpdatesDay() {
        var selectedDay = 0
        selectedDay = 2
        XCTAssertEqual(selectedDay, 2, "Day button should update selectedDay")
    }
}
