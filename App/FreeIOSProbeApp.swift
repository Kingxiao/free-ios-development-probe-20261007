import SwiftUI

@main
struct FreeIOSProbeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "iphone")
                .font(.system(size: 56))
            Text("Free iOS Probe")
                .font(.largeTitle)
            Text("Native SwiftUI app")
                .foregroundStyle(.secondary)
            Text(String(count))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .accessibilityIdentifier("counter")
            Button("Add one") {
                count += 1
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("increment")
            Button("Reset") {
                count = 0
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("reset")
        }
        .padding()
    }
}
