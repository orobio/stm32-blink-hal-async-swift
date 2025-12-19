import Synchronization

/// Guard data that is used both from main loop and interrupts.
///
/// The guard makes sure that interrupts are disabled while the data is accessed.
///
struct InterruptGuard<Data>: ~Copyable {
    private var data: Synchronization._Cell<Data>

    init(_ data: Data) {
        self.data = _Cell(data)
    }

    mutating func withInterruptsDisabled<Result>(
        _ body: (inout sending Data) -> sending Result
    ) -> Result {
        return _withInterruptsDisabled {
            return body(&data._address.pointee)
        }
    }
}

/// Execute a closure while interrupts are disabled.
///
func withInterruptsDisabled<T>(_ body: () -> T) -> T {
    _withInterruptsDisabled(body)
}

private func _withInterruptsDisabled<T>(_ body: () -> T) -> T {
    let primask = __get_PRIMASK() // Save current state
    __disable_irq() // Disable all maskable IRQs
    defer { __set_PRIMASK(primask) } // Restore previous state
    return body()
}
