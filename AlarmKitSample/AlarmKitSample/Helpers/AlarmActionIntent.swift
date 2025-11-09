//
//  AlarmActionIntent.swift
//  AlarmKitSample
//
//  Created by 藤治仁 on 2025/11/10.
//

import WidgetKit
import SwiftUI
import AlarmKit
import AppIntents

struct AlarmActionIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Alarm Action"
    static var isDiscoverable: Bool = false
    
    @Parameter
    var id: String

    @Parameter
    var isCancel: Bool
    
    @Parameter
    var isResume: Bool

    init(id: UUID, isCancel: Bool, isResume: Bool = false) {
        self.id = id.uuidString
        self.isCancel = isCancel
        self.isResume = isResume
    }
    
    init() {
    }
    
    func perform() async throws -> some IntentResult {
        // AlarmManager, a shared instance, enables us to manage alarms and provides various properties, such as alarms and alarmUpdates. With these properties, we can gain insights into the active and upcoming alarms.
        
        if let alarmID = UUID(uuidString: id) {
            if isCancel {
                /// Cancel Alarm
                try AlarmManager.shared.cancel(id: alarmID)
            } else {
                if isResume {
                    // Resume Alarm
                    try AlarmManager.shared.resume(id: alarmID)
                } else {
                    /// Pause  Alarm
                    try AlarmManager.shared.pause(id: alarmID)
                }
            }
        }
        
        return . result()
    }
}
