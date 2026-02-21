import SwiftUI

struct HomeView: View {
    @State private var vm = NetworkVM()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        List {
            Text(vm.ingoing)
            Text(vm.outgoing)
        }
        .monospacedDigit()
        .task {
            vm.calculateSpeed()
        }
        .onReceive(timer) { _ in
            vm.calculateSpeed()
        }
    }
}

#Preview {
    HomeView()
}
