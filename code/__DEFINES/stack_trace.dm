/// Gives us the stack trace from CRASH() without ending the current proc.
#define stack_trace(message) _stack_trace(message, __FILE__, __LINE__)

var/global/list/stack_trace_storage

/**
 *? Gives us the stack trace from CRASH() without ending the current proc.
 *! Do not call directly, use the [stack_trace] macro instead.
 */
/proc/_stack_trace(message, file, line)
	CRASH("[message] ([file]:[line])")

/proc/gib_stack_trace()
	stack_trace_storage = list()
	stack_trace("")
	stack_trace_storage.Cut(1, min(3,stack_trace_storage.len))
	. = stack_trace_storage
	stack_trace_storage = null