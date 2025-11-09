//
//  CountDownLiveActivity.swift
//  CountDown
//
//  Created by 藤治仁 on 2025/11/09.
//

import WidgetKit
import SwiftUI
import AlarmKit
import AppIntents

// As you can notice we have setup everything needed for a countdown based alarm, but the only one thing missing from here is the LiveActivity which actually displays this information, thus let's create a new live activity whichj will display the alarm Ul.
// Note: Under some instances the system will displays it's default Ul for the countdown than our custom UI!

struct CountDownLiveActivity: Widget {
    /// Number Formatter
    @State private var formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AlarmAttributes<CountDownAttribute>.self) { context in
            // For the tutorial, I'Il just create the LiveActivity Ul. You can then use this Ul to fit into Dynamic Island
            // UI areas!
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    switch context.state.mode {
                    case .countdown(let countdown):
                        Group {
                            Text(context.attributes.presentation.countdown?.title ?? "")
                                .font(.title3)
                            Text(countdown.fireDate, style: .timer)
                                .font(.title2)
                        }
                        
                    case .paused(let paused):
                        Group {
                            Text(context.attributes.presentation.paused?.title ?? "")
                                .font(.title3)
                            Text(formatter.string(from: paused.totalCountdownDuration - paused.previouslyElapsedDuration) ?? "0:00")
                                .font(.title2)
                        }
                        
                    case .alert(_):
                        Group {
                            Text(context.attributes.presentation.alert.title)
                                .font(.title3)
                            Text("0:00")
                                .font(.title2)
                        }
                        
                    @unknown default:
                        fatalError()
                    }
                } // VStack
                .lineLimit(1)
                
                Spacer(minLength: 0)
                
                let alarmID = context.state.alarmID
                
                /// Pause and Cancel Buttons!
                Group {
                    // This is crucial, as you've already noticed that the intents aren't working. The reason for this is that the LiveActivitylntent must be shared with the App as well. Therefore, let's create a separate file for intents that will be shared between the App and its extensions!
                    
                    if case .paused = context.state.mode {
                        Button (intent: AlarmActionIntent(id: alarmID, isCancel: false, isResume: true)) {
                            Image(systemName: "play.fill")
                        }
                        .tint(.orange)
                    } else {
                        Button (intent: AlarmActionIntent(id: alarmID, isCancel: false)) {
                            Image(systemName: "pause.fill")
                        }
                        .tint(.orange)
                    }
                    
                    Button (intent: AlarmActionIntent(id: alarmID, isCancel: true)) {
                        Image(systemName: "xmark")
                    }
                    .tint(.red)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.circle)
                .font(.title)
            }
            .padding(15)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("Minimal Content")
            }
            .keylineTint(Color.red)
        }
    }
}
