import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Settings")) {
                Toggle("Example Setting", isOn: .constant(true))
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
