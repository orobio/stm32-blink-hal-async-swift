import _Concurrency

/// Continuously running clock.
///
/// Runs with a resolution of 1 millisecond.
///
struct ContinuousClock: Clock {
    public struct Instant: InstantProtocol, CustomStringConvertible {
        fileprivate var _value: Swift.Duration

        var description: String { "\(_value.attoseconds / 1_000_000_000_000_000) ms" }

        func advanced(by duration: Duration) -> Self {
            Self(_value: self._value + duration)
        }

        func duration(to other: Self) -> Duration {
            other._value - self._value
        }

        static var now: Self {
            ContinuousClock.now
        }

        static var epoch: Self {
            Self(_value: .milliseconds(0))
        }

        static func <(left: Self, right: Self) -> Bool {
            left._value < right._value
        }

        fileprivate init(_value: Swift.Duration) {
            self._value = _value
        }

        fileprivate func getTickTimeMS() -> UInt64 {
            UInt64(_value.attoseconds / 1_000_000_000_000_000) // A custom Duration would make this more efficient
        }
    }

    let minimumResolution = Swift.Duration.milliseconds(1)

    var now: Instant {
        Self.now
    }

    var epoch: Instant {
        Self.epoch
    }

    var uptime: Duration {
        Self.uptime
    }

    func sleep(until deadline: Instant, tolerance: Duration?) async throws {
        try await ContinousClockImpl.sleep(until: deadline.getTickTimeMS())
    }

    static var now: Instant {
        Instant(_value: .milliseconds(ContinousClockImpl.getTickTimeMS()))
    }

    static var epoch: Instant {
        Instant.epoch
    }

    static var uptime: Duration {
        self.now._value
    }
}

/// Implementation for Continuous clock.
///
/// The tick time is increased by an interrupt every millisecond.
/// When necessary, the interrupt schedules a tasklet to handle expired timers.
/// The tasklet will set its own schedule time, if there are any active timers.
///
private enum ContinousClockImpl {
    struct InterruptData {
        var tickTimeMS: UInt64 = 0
        var taskletScheduleTime: UInt64 = .max
    }

    struct Timer {
        let deadline: UInt64
        let continuation: UnsafeContinuation<Void, Never>
    }

    static var interruptData = InterruptGuard(InterruptData())
    static var timers = [Timer]()

    static func getTickTimeMS() -> UInt64 {
        interruptData.withInterruptsDisabled { data in data.tickTimeMS }
    }

    static func updateTaskletScheduleTime() {
        interruptData.withInterruptsDisabled { data in
            data.taskletScheduleTime = timers.first?.deadline ?? .max
        }
    }

    /// Increase tick time and check whether the tasklet schedule time has been reached.
    ///
    /// Note: The tasklet schedule time is reset when this function returns true! Subsequent calls will
    ///       return false until the tasklet schedule time is set again.
    ///
    /// - Returns: True if the tasklet schedule time has been reached.
    ///
    static func increaseTickTimeMSAndCheckTaskletScheduleTime() -> Bool {
        interruptData.withInterruptsDisabled { data in
            data.tickTimeMS += 1
            if data.tickTimeMS >= data.taskletScheduleTime {
                data.taskletScheduleTime = .max
                return true
            } else {
                return false
            }
        }
    }

    static func sleep(until timeTickMSDeadline: UInt64) async throws {
        await withUnsafeContinuation { continuation in
            Self.timers.insertBasedOnDeadline(Timer(deadline: timeTickMSDeadline, continuation: continuation))
            Self.scheduleTasklet()
        }
    }

    static func processTimers() {
        let now = getTickTimeMS()
        while let first = Self.timers.first {
            guard first.deadline < now else { return }

            first.continuation.resume()
            Self.timers.removeFirst()
        }
    }

    static func scheduleTasklet() {
        TaskletExecutor.schedule {
            Self.processTimers()

            // Make sure the interrupt handler schedules this tasklet when the next timer expires.
            Self.updateTaskletScheduleTime()
        }
    }
}

/// Interrupt handler.
///
/// Called every 1 ms from HAL_IncTick.
/// Increases the tick time and schedules the tasklet when the tasklet schedule time is reached.
/// The tasklet will process any expired timers on the main loop.
///
@_cdecl("swift_ContinuousClock_HAL_IncTick")
func swift_ContinuousClock_HAL_IncTick() {
    if ContinousClockImpl.increaseTickTimeMSAndCheckTaskletScheduleTime() {
        ContinousClockImpl.scheduleTasklet()
    }
}

fileprivate extension [ContinousClockImpl.Timer] {
    /// Insert a timer, keeping them sorted so that the first to expire is at the start.
    ///
    mutating func insertBasedOnDeadline(_ toBeInserted: ContinousClockImpl.Timer) {
        var insertIndex = self.endIndex
        for index in self.indices {
            if self[index].deadline > toBeInserted.deadline {
                insertIndex = index
                break
            }
        }
        self.insert(toBeInserted, at: insertIndex)
    }
}
