/// Tasklet executor.
///
/// Tasklets can be scheduled from interrupts to do high priority work on the main loop.
/// They can be used to resume Swift concurrency continuations, which is not safe to do from an interrupt.
///
enum TaskletExecutor {
    typealias Tasklet = @convention(c) () -> ()
    private static var scheduledTasklets = InterruptGuard(TaskletArray<32>())

    static func schedule(_ tasklet: Tasklet) {
        scheduledTasklets.withInterruptsDisabled { $0.append(tasklet) }
    }

    static func executeAllScheduledTasklets() {
        let runQueue = scheduledTasklets.withInterruptsDisabled { $0.getAndRemoveAll() }
        runQueue.executeAll()
    }
}

/// Array of tasklets.
///
/// A fixed capacity array for tasklets.
///
/// FIXME: Copies of the array are inefficient. They always result in a copy of the full capacity, including empty elements.
///
private struct TaskletArray<let capacity: Int> {
    private var tasklets = InlineArray<capacity, TaskletExecutor.Tasklet?>(repeating: nil)
    private(set) var count = 0

    mutating func append(_ tasklet: TaskletExecutor.Tasklet) {
        guard count < capacity else {
            fatalError("Reached maximum capacity")
        }

        tasklets[count] = tasklet
        count += 1
    }

    mutating func removeAll() {
        count = 0
    }

    mutating func getAndRemoveAll() -> Self {
        defer { removeAll() }
        return self
    }

    func executeAll() {
        for index in 0 ..< count {
            tasklets[index]!()
        }
    }
}
