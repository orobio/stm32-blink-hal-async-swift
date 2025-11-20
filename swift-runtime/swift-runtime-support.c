// *****************
// Functions required by swift-runtime via stdc++/newlib
// *****************

#include "stm32f4xx_hal.h"
#include <sys/time.h>
#include <malloc.h>


int _gettimeofday (struct timeval *__p, void *__tz)
{
    return -1; // Always fail
}

int nanosleep (const struct timespec *, struct timespec *)
{
    return -1; // Always fail
}

int posix_memalign(void **memptr, size_t alignment, size_t size)
{
    if (alignment % sizeof(void*) != 0 || (alignment & (alignment - 1)) != 0)
    {
        return -1;
    }

    void *p = memalign(alignment, size);
    if (!p)
    {
        return -1;
    }

    *memptr = p;
    return 0;
}


// *****************
// Compiler built-in functions for 64-bit atomics.

long long unsigned int __atomic_load_8(const volatile void* addr, int val2)
{
	uint32_t primask = __get_PRIMASK(); // Save current state
    __disable_irq(); // Disable all maskable IRQs
	long long unsigned int value = *(const volatile long long unsigned int*)addr;
	__set_PRIMASK(primask); // Restore previous state
	return value;
}

void __atomic_store_8(const volatile void* addr, long long unsigned int val1, int val2)
{
	uint32_t primask = __get_PRIMASK(); // Save current state
    __disable_irq(); // Disable all maskable IRQs
	*(volatile long long unsigned int*)addr = val1;
	__set_PRIMASK(primask); // Restore previous state
}

_Bool __atomic_compare_exchange_8(
    volatile void* ptr,
    void* expected,
    long long unsigned int desired,
    _Bool weak,
    int success_memorder,
    int failure_memorder
)
{
	uint32_t primask = __get_PRIMASK(); // Save current state
    __disable_irq(); // Disable all maskable IRQs
    long long unsigned int* target = (long long unsigned int*)ptr;
    long long unsigned int* expected_val = (long long unsigned int*)expected;

    if (*target == *expected_val) {
        *target = desired;
		__set_PRIMASK(primask); // Restore previous state
		return 1;
    } else {
        *expected_val = *target;
		__set_PRIMASK(primask); // Restore previous state
        return 0;
    }
}

long long unsigned int __atomic_fetch_sub_8(
    volatile void* ptr,
    long long unsigned int val,
    int memorder
)
{
	uint32_t primask = __get_PRIMASK(); // Save current state
    __disable_irq(); // Disable all maskable IRQs
    long long unsigned int* target = (long long unsigned int*)ptr;
    long long unsigned int original = *target;
    *target = original - val;
	__set_PRIMASK(primask); // Restore previous state
    return original;
}

long long unsigned int __atomic_fetch_add_8(
    volatile void* ptr,
    long long unsigned int val,
    int memorder
)
{
	uint32_t primask = __get_PRIMASK(); // Save current state
    __disable_irq(); // Disable all maskable IRQs
    long long unsigned int* target = (long long unsigned int*)ptr;
    long long unsigned int original = *target;
    *target = original + val;
	__set_PRIMASK(primask); // Restore previous state
    return original;
}

long long unsigned int __atomic_fetch_or_8(
    volatile void* ptr,
    long long unsigned int val,
    int memorder
)
{
	uint32_t primask = __get_PRIMASK(); // Save current state
    __disable_irq(); // Disable all maskable IRQs
    long long unsigned int* target = (long long unsigned int*)ptr;
    long long unsigned int original = *target;
    *target = original | val;
	__set_PRIMASK(primask); // Restore previous state
    return original;
}
