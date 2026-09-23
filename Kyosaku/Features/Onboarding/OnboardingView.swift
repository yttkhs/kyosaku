import SwiftUI

/// The one-page first-launch welcome. A placeholder until its real content is written.
struct OnboardingView: View {
    let onGetStarted: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to Kyosaku")
                .font(.title)
            VStack(spacing: 4) {
                Text("Kyosaku gently nudges you when what's on your screen drifts away from your task.")
                Text("It never blocks anything, and everything stays on your Mac.")
            }
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
            Button("Get Started", action: onGetStarted)
                .keyboardShortcut(.defaultAction)
                .accessibilityIdentifier("onboarding.getStartedButton")
        }
        .padding(32)
        .frame(width: 440)
    }
}
