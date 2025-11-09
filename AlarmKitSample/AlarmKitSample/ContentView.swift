//
//  ContentView.swift
//  AlarmKitSample
//
//  Created by 藤治仁 on 2025/11/09.
//

import SwiftUI
import AlarmKit
import AppIntents

struct ContentView: View {
    @State private var isAuthorized: Bool = false
    @State private var scheduleDate: Date = .now
    var body: some View {
        NavigationStack {
            Group {
                if isAuthorized {
                    AlarmView()
                }
                else {
                    Text ("You need to allow alarms in settings to use this app")
                        .multilineTextAlignment(.center)
                        .padding (10)
                        .glassEffect()
                }
            }
            .navigationTitle("AlarmKit")
        }
        .task {
            // This will require us to add a "Privacy-AlarmKit Usage Description" in our app's info.plist file!
            do {
                try await checkAndAuthorize()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @ViewBuilder
    private func AlarmView() -> some View {
        List {
            // As you observed in the demo video, there are two types of alarms that can be presented to the user:
            // 1. Alarm Only type
            // 2. Alarm with a countdown (Displayed on LiveActivity, Dynamic Island, etc.)
            // Now, let's begin by creating an alarm-only type!
            Section("Date & Time") {
                DatePicker("", selection: $scheduleDate, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
            }
            
            Button("Set Alarm") {
                Task {
                    do {
                        try await setAlarm()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
            Button("Set Countdown Alarm") {
                Task {
                    do {
                        try await setAlarmWithCountdown()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func setAlarm() async throws {
        // Creating an alarm is a simple process that requires the creation of specific components for its creation and addition to the system.
        // 1. Alarm Alert
        // 2. Alarm Presentation
        // 3. Alarm Attributes
        // 4. Alarm Schedule
        // 5. Alarm Configuration
        // Finally, an AlarmID, and with this, we can create and add alarms to the system.
        
        // Alert Presentation can be configured with another secondary button that can have custom Intent actions. Let's create a sample button and an intent that, when tapped, will open the actual app.
        
        /// AlarmID
        let id = UUID()
        
        /// Secondary Alert Button
        let secondaryButton = AlarmButton(text: "Go to App", textColor: .white, systemImageName: "app.fill")
        
        /// Alert
        let alert = AlarmPresentation.Alert(
            title: "Time's Up!!",
            stopButton: .init(text: "Stop", textColor: .red, systemImageName: "stop.fill"),
            secondaryButton: secondaryButton,
            // The "countdown" type is designed for countdown-based alarms that can be configured to simply snooze with the post-time countdown settings provided by the user.
            // For alarm-only presentations, this type will have no effect, so let's use the custom type instead.
            secondaryButtonBehavior: .custom
        )
        
        /// Presentation
        let presentation = AlarmPresentation(alert: alert)
        
        ///Attributes
        ///AlarmAttributes requires the creation of a struct that conforms to the AlarmMetaData protocol.
        /// This will provides additional data to the Alarm Ul for LiveActivity and Dynamic Island, among other functionalities.
        let attributes = AlarmAttributes<CountDownAttribute>(presentation: presentation, metadata: .init(), tintColor: .orange)
        
        /// Schedule
        /// Alarm Schedule has two types:
        /// 1. Fixed: This type of alarm has a fixed date and time.
        /// 2. Relative: This type of alarm is time-based and will repeat according to the given information.
        let schedule = Alarm.Schedule.fixed(scheduleDate)
        
        /// Configuration
        let configuration = AlarmManager.AlarmConfiguration(
            schedule: schedule,
            attributes: attributes,
            secondaryIntent: OpenAppIntent(id: id)
        )
        
        /// Adding alarm to the System
        let _  = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
        
        print("Alarm Set Successfully")
    }

    private func setAlarmWithCountdown() async throws {
        // Now, let's explore how we can create an alarm with a countdown feature!
        // This process essentially involves the same five steps we used to create a regular alarm. However, in this case, we need to introduce a few additional elements, such as a pause button, a resume button, a countdown, and a countdown title.
        // Let's begin modifying the code to incorporate these changes!
        
        /// AlarmID
        let id = UUID()
        
        /// Countdown
        /// PreAlert is the countdown before the first innovation of the alarm, while PostAlert is the countdown after pressing the secondary action with a countdown behaviour type (similar to snoozing).
        // Both values are in seconds!
        // 
        // This is how it works!
        // Now, let's create intent actions for the Pause and Cancel buttons to perform their respective actions!
        let alarmCountdown = Alarm.CountdownDuration(preAlert: 20, postAlert: 10)
        
        /// Secondary Alert Button
        let secondaryButton = AlarmButton(text: "Repeat", textColor: .white, systemImageName: "arrow.clockwise")
        
        /// Alert
        let alert = AlarmPresentation.Alert(
            title: "Time's Up!!",
            stopButton: .init(text: "Stop", textColor: .red, systemImageName: "stop.fill"),
            secondaryButton: secondaryButton,
            // The "countdown" type is designed for countdown-based alarms that can be configured to simply snooze with the post-time countdown settings provided by the user.
            // For alarm-only presentations, this type will have no effect, so let's use the custom type instead.
            secondaryButtonBehavior: .countdown
        )
        
        let countdownPresentation = AlarmPresentation.Countdown(
            /// Your title to be displayed on Live activity, Dynamic Island etc.
            title: "Coding",
            pauseButton: .init(
                text: "Pause",
                textColor: .white,
                systemImageName: "pause.fill"
            )
        )
        
        let pausePresentation = AlarmPresentation.Paused(
            /// Pause title to be displayed on Live activity, Dynamic Island etc.
            title: "Paused!",
            resumeButton: .init(
                text: "Resume",
                textColor: .white,
                systemImageName: "play.fill"
            )
        )
        
        /// Presentation
        let presentation = AlarmPresentation(
            alert: alert,
            countdown: countdownPresentation,
            paused: pausePresentation
        )
        
        ///Attributes
        ///AlarmAttributes requires the creation of a struct that conforms to the AlarmMetaData protocol.
        /// This will provides additional data to the Alarm Ul for LiveActivity and Dynamic Island, among other functionalities.
        let attributes = AlarmAttributes<CountDownAttribute>(presentation: presentation, metadata: .init(), tintColor: .orange)
        
        /// Configuration
        let configuration = AlarmManager.AlarmConfiguration(
            // Countdown-type alarms work even without any scheduling. So, remember this:
            // - Regular alarms require scheduling.
            // - Countdown alarms are optional to schedule, but the countdown, pause, and resume actions are necessary!
            countdownDuration: alarmCountdown,
            attributes: attributes
        )
        
        /// Adding alarm to the System
        let _  = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
        
        print("Alarm Set With Countdown Successfully")
    }

    private func checkAndAuthorize() async throws {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            // Requesting for authorization
            let status = try await AlarmManager.shared.requestAuthorization()
            isAuthorized = status == .authorized
            
        case .denied:
            isAuthorized = false
            
        case .authorized:
            isAuthorized = true
            
        @unknown default:
            fatalError()
        }
    }
}

#Preview {
    ContentView()
}
