/// The global executor.
///
/// Very basic executor that runs async jobs and tasklets indefinitely.
///
fileprivate enum GlobalExecutor {
    /// Job queue.
    ///
    private static var jobs = [Job]() // A proper queue would be more efficient

    /// Enqueue a job.
    ///
    static func enqueue(_ job: Job) {
        jobs.append(job)
    }

    /// Main run loop.
    ///
    static func run() -> Never {
        while true {
            // Run scheduled tasklets, if any.
            TaskletExecutor.executeAllScheduledTasklets()

            // Run next job if available.
            if !jobs.isEmpty {
                let nextJob = jobs.removeFirst()
                nextJob.runSynchronouslyOnTheGenericExecutor()
            }
        }
    }
}

/// Job.
///
fileprivate struct Job {
    let swiftJob: UnsafeMutablePointer<SwiftJob>

    /// Run the job on the generic executor.
    ///
    func runSynchronouslyOnTheGenericExecutor() {
        _swift_job_run_c(swiftJob, swift_executor_generic())
    }
}

/***********************************************************************
 * Replace default executor from the Swift runtime.
 *
 * We do this by not linking with libswift_ConcurrencyDefaultExecutor.a
 * and providing our own functions below.
 ***********************************************************************/

@_silgen_name("swift_task_asyncMainDrainQueueImpl")
public func swift_task_asyncMainDrainQueueImpl() -> Never {
    // The compiler inserts a call to this function into main.
    // All work will be executed by the global executor.
    GlobalExecutor.run()
}

@_silgen_name("swift_task_enqueueGlobalImpl")
public func swift_task_enqueueGlobalImpl(swiftJob: UnsafeMutablePointer<SwiftJob>) {
    GlobalExecutor.enqueue(Job(swiftJob: swiftJob))
}

@_silgen_name("swift_task_getMainExecutorImpl")
public func swift_task_getMainExecutorImpl() -> SwiftExecutorRef {
    return swift_executor_generic()
}
