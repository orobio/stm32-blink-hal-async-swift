import _Concurrency

// Use ContinuousClock to implement Task sleep functions.
extension Task where Success == Never, Failure == Never {
    static func sleep(until deadline: ContinuousClock.Instant, tolerance: Duration? = nil) async throws {
        try await ContinuousClock().sleep(until: deadline, tolerance: tolerance)
    }

    static func sleep(for duration: Duration, tolerance: Duration? = nil) async throws {
        try await ContinuousClock().sleep(for: duration, tolerance: tolerance)
    }
}
