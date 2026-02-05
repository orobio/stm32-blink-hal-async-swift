
#ifndef BRIDGING_HEADER_H
#define BRIDGING_HEADER_H

#include "main.h"
#include "ExecutorImpl.h"

extern void _swift_job_run_c(SwiftJob * _Nonnull job,
                             SwiftExecutorRef executor);

#endif // BRIDGING_HEADER_H
