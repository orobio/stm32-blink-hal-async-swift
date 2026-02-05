import _Concurrency

@main
struct Main {
    static func main() async throws {
        Initialize_Hardware();

        try await withThrowingDiscardingTaskGroup { group in
            // #################
            // Blink LED
            // #################
            group.addTask {
                while true {
                    Switch_On_LED()
                    try await Task.sleep(for: .seconds(0.5))
                    Switch_Off_LED()
                    try await Task.sleep(for: .seconds(0.5))
                }
            }

            // #################
            // Print uptime
            // #################
            group.addTask {
                while true {
                    print("uptime: \(ContinuousClock.uptime.components.seconds) seconds")
                    try await Task.sleep(for: .seconds(1))
                }
            }
        }
    }
}
