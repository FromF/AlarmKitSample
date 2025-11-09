//
//  OpenAppIntent.swift
//  AlarmKitSample
//
//  Created by 藤治仁 on 2025/11/09.
//

import SwiftUI
import AppIntents

struct OpenAppIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Opens App"
    static var openAppWhenRun: Bool = true
    static var isDiscoverable: Bool = false
    
    @Parameter
    var id: String
    
    init(id: UUID) {
        self.id = id.uuidString
    }
    
    init() {
    }
    
    func perform() async throws -> some IntentResult {
        if let alarmID = UUID(uuidString: id) {
            print (alarmID)
            /// Do your custom code here...
        }
        return .result()
    }
}
