//
//  Music2UITests.swift
//  Music2UITests
//
//  Created by 平野翔太郎 on 2021/07/30.
//

import XCTest
import MetricKit
@testable import Music2

@available(iOS 14.0, *)
class Music2UITests: XCTestCase {
    func testTopMetric() {
        let app = XCUIApplication()
        app.launch()
        sleep(20)
        if app.exists, app.isHittable, app.isEnabled {
            let measureOptions = XCTMeasureOptions()
            measureOptions.invocationOptions = [.manuallyStop]
            self.measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric], options: measureOptions) {
                app.swipeUp(velocity: .fast)
                self.stopMeasuring()
                app.swipeUp(velocity: .fast)
            }
        }
    }
    
    
    func testApplicationLaunchTime() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
