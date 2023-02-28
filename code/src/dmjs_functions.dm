
/**
 * Sends `data` in a BYOND URL to the form: "byond://?src=[refcode]&[data]"
 */
#define DMJS_SEND_DATA {"function dmui_sendData(data) { window.location = "byond://?src=\ref[src]&" + data; }"}

/**
 * Sends `action` as the value for the action param: "byond://?src=[refcode]&action=[action]"
 */
#define DMJS_SEND_ACTION {"function dmui_sendAction(action) { window.location = "byond://?src=\ref[src]&action=" + action; }"}

/**
 * Sends `action` and `value` as values for the params: "byond://?src=[refcode]&action=[action]&value=[value]"
 */
#define DMJS_SEND_ACTION_DATA {"function dmui_sendActionData(action, value) { window.location = "byond://?src=\ref[src]&action=" + action + "&value=" + value; }"}

/**
 * Sends a `name=value` pair through the link to the form: "byond://?src=[refcode]&[name]=[value]"
 */
#define DMJS_SEND {"function dmui_send(name, value) { window.location = "byond://?src=\ref[src]&name=" + name + "&value=" + value; }"}

/**
 * Sends the `name` and `value` in two pair for an input control: "byond://?src=[refcode]&name=[input.name]&value=[input.value]"
 */
#define DMJS_SET {"function dmui_set(input) { window.location = "byond://?src=\ref[src]&name=" + input.name + "&value=" + input.value; }"}

/**
 * Given a checkmark input control, returns the state of the checkmark as "true" or "false": "byond://?src=[refcode]&name=[input.name]&value=[input.checked]"
 */
#define DMJS_CHECK {"function dmui_check(input) { window.location = "byond://?src=\ref[src]&name=" + input.name + "&value=" + input.checked; }"}

/**
 * Writing this as a define just to make it easier to read.
 */
#define DMJS_FUNCTIONS "[DMJS_SEND_DATA] [DMJS_SEND_ACTION] [DMJS_SEND_ACTION_DATA] [DMJS_SEND] [DMJS_SET] [DMJS_CHECK]"
