import Foundation

@Observable
final class NetworkVM {
    var previousData: NetworkSpeed?
    
    var ingoing = ""
    var outgoing = ""
    
    func calculateSpeed() {
        guard let currentData = getNetworkData() else {
            return
        }
        
        if let previousData {
            let receivedDiff = currentData.receivedBytes - previousData.receivedBytes
            let sentDiff = currentData.sentBytes - previousData.sentBytes
            
            let receivedSpeed = Double(receivedDiff) / 1 // In bytes per second
            let sentSpeed = Double(sentDiff) / 1        // In bytes per second
            
            ingoing = "Incoming speed: \(String(format: "%.1f", receivedSpeed / 1024)) KB/s"
            outgoing = "Outgoing speed: \(String(format: "%.1f", sentSpeed / 1024)) KB/s"
        }
        
        previousData = currentData
    }
    
    private func getNetworkData() -> NetworkSpeed? {
        let task = Process()
        task.launchPath = "/usr/sbin/netstat"
        task.arguments = ["-ib"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        var receivedBytes: UInt64 = 0
        var sentBytes: UInt64 = 0
        
        // Parse the netstat output
        let lines = output.split(separator: "\n")
        
        for line in lines {
            // Use the appropriate network interface, typically "en0" for Wi-Fi
            
            if line.contains("en0") {
                let columns = line.split(separator: " ").filter {
                    !$0.isEmpty
                }
                
                if columns.count >= 7 {
                    // Column 6 is Ibytes (incoming bytes) and column 9 is Obytes (outgoing bytes)
                    if let ibytes = UInt64(columns[6]), let obytes = UInt64(columns[9]) {
                        receivedBytes += ibytes
                        sentBytes += obytes
                    }
                }
            }
        }
        
        return NetworkSpeed(
            receivedBytes: receivedBytes,
            sentBytes: sentBytes
        )
    }
}
