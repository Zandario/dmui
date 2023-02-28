
/// Set up variables and call user-defined get_html_layout().
/datum/dmui_form/proc/get_html(datum/dmui_form/parent_form)

	var/html
	var/body
	var/datum/dmui_var/fv

	form_is_sub = (parent_form && parent_form != src)

	//? Generate html code for each input variable
	for(fv in form_vars)
		fv.value = vars[fv.name]

		switch(fv.interface)
			if(RADIO_OPTION)
				fv.checked = (vars[fv.radio_name] == fv.value)

			if(BUTTON,PROMPT)
				if(form_byond_mode)
					fv.click_script = get_button_script(fv.name, parent_form)

				else //assume this is an upload field
					form_method = "post"
					form_enctype = "multipart/form-data"

			if(SELECT,MULTI_SELECT,CHECKLIST,RADIO_LIST,HIDDEN_LIST)
				var/var_values = "[fv.name]_values"

				if(var_values in vars)
					fv.values = vars[var_values]

		fv.html_value = html_encode(fv.value)

		vars[fv.name] = fv.generate_input_tag(src, form_var_prefix)

	//? User generates html by inserting form variables.
	body = get_html_layout()

	//? Restore variables and tag on hidden ones
	for(fv in form_vars)
		if(fv.hidden)
			body += vars[fv.name]

		vars[fv.name] = fv.value

	if(!form_is_sub)
		//? Add the <form> wrapper.

		var/encoding
		var/method = form_method

		if(form_enctype)
			encoding = " enctype=[form_enctype]"

		if(form_byond_mode)
			//? Post does not work in Dream Seeker.
			method = "get"

		html = "<form method=[method][encoding] action='[get_submit_url(form_sub_path)]' [form_extra]>\n"
		html += "<input type=hidden name=src value='[html_encode("\ref[src]")]'>\n"

		html += "[body]\n</form>"
	else
		html = body

	return html


/datum/dmui_form/proc/get_submit_url(sub_path)
	if(form_url)
		return form_url

	var/url = "byond://"
	if(sub_path)
		url = "[url]/[sub_path]"

	return url


/// Return URL containing all form variables or specified parameters.
/datum/dmui_form/proc/get_self_url(params, mob/user, passive)

	var/plist[0]

	if(ismob(params) && !user)
		//? Shuffle args around for backwards compatibility
		user = params
		params = null

	if(params || params == "")
		if(istext(params))
			plist = params2list(params)
		else
			plist = params
	else
		for(var/datum/dmui_var/our_var as anything in form_vars)
			switch(our_var.interface)
				if(RADIO_OPTION,BUTTON,PROMPT,SUBMIT,RESET)
					continue

			plist[our_var.name] = vars[our_var.name]

	plist["src"] = src

	if(!passive)
		start_waiting()

	return html_encode("[get_submit_url(form_sub_path)]?[list2params(plist)]")


/datum/dmui_form/proc/get_button_script(name, datum/dmui_form/parent_form)
	return {"document.location.href="[get_self_url(form_var_prefix + name, user, passive=TRUE)]""}


/datum/dmui_form/proc/get_js_functions(javascript)
	SHOULD_CALL_PARENT(TRUE)
	return {"<script language="javascript"> [DMJS_FUNCTIONS] [javascript ? javascript : null] </script>"}

/datum/dmui_form/proc/get_html_header()
	. = get_js_functions()
	if(form_title)
		. += "<title>[form_title]</title>"

/// Returns form as a stand-alone document.
/datum/dmui_form/proc/get_html_body()
	var/head = get_html_header()
	var/body = get_html()

	return \
{"

<!DOCTYPE html>
<html>
<meta charset='utf-8'>
<meta http-equiv='X-UA-Compatible' content='IE=edge'>
<meta http-equiv='content-language' content='en-us' />
<head>[head]</head>
<body>[body]</body>
</html>

"}


/**
 * Call this to send form to user.
 * Do everything except display the form.
 */
/datum/dmui_form/proc/setup_form(mob/user)
	if(form_waiting)
		world.log << "Error: display_form([user]) called before previous submission finished."
		form_waiting = null
		form_wait_count = 0

	//? Set the user for this form.
	src.user = user || usr

	if(!user.client)
		//? No sense in creating form for NPC.
		return

	window_key = "\ref[type]"

	Initialize()

	for(var/datum/dmui_var/our_var as anything in form_vars)
		if(our_var.interface == SUB_FORM)
			var/datum/dmui_form/sub_form = vars[our_var.name]
			//TODO: could call sub_form.setup_form() here but code currently assumes lack of start_waiting() call on sub-forms
			sub_form.Initialize()

	start_waiting()


/// Called in `display_form()`.
/datum/dmui_form/proc/Initialize(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	return TRUE

#define COMPILE_ARGS "window=[window_key]\ref[host]&size=[window_size]\
	[window_param_flags & DMUI_NO_TITLEBAR     ? "&titlebar=0"     : ""]\
	[window_param_flags & DMUI_CANNOT_CLOSE    ? "&can_close=0"    : ""]\
	[window_param_flags & DMUI_CANNOT_RESIZE   ? "&can_resize=0"   : ""]\
	[window_param_flags & DMUI_CANNOT_MINIMIZE ? "&can_minimize=0" : ""]\
	[window_param_flags & DMUI_CANNOT_MAXIMIZE ? "&can_maximize=0" : ""]\
	[window_param_flags & DMUI_CANNOT_SCROLL   ? "&can_scroll=0"   : ""]"

/datum/dmui_form/proc/display_form(mob/user)
	setup_form(user)
	window_compiled_params = COMPILE_ARGS
	user << browse(get_html_body(), window_compiled_params)
	user << output(window_compiled_params)

	#ifdef DMUI_VERBOSE_LOGGING
	user << output(html_encode("[get_html_body()]"))
	#endif


/// Called when the form is complete.
/datum/dmui_form/proc/process_form()
	return


/**
 * Call this to submit a filled out form.
 *
 * This is primarily used by CGI scripts on the web
 * optional params list contains the pre-parsed contents of href
 */
/datum/dmui_form/proc/submit_form(href, mob/user, params)
	if(!form_wait_count)
		start_waiting()

	return Topic(href, params)


/datum/dmui_form/proc/start_waiting()
	if(isnull(user))
		world.log << "Error: start_waiting() called without a user."
		return
	form_waiting = src //avoid garbage collector
	form_wait_count += 1


/datum/dmui_form/proc/stop_waiting()
	if(form_wait_count)
		form_wait_count -= 1

	if(!form_wait_count)
		if(form_reusable)
			//? Reset wait counter.
			form_wait_count = 1
		else
			user = null
			form_waiting = null

		process_form()


/datum/dmui_form/proc/capitalize(txt)
	return uppertext(copytext(txt, 1, 2)) + copytext(txt, 2)


/**
 * Returns html text.
 *
 * The default get_html_layout() is almost always overridden by the user.
 * It makes a very simple (and probably ugly) form interface for the given variables.
 * It does make rapid form development a breeze, though.
 */
/datum/dmui_form/proc/get_html_layout()
	var/datum/dmui_var/fv
	var/html

	for(fv in form_vars)
		if(fv.hidden)
			continue //hidden variables are automatically inserted

		if(fv.interface == SUBMIT || fv.interface == RESET || fv.interface == RADIO)
			continue

		if(fv.interface != RADIO_OPTION && fv.interface != BUTTON && fv.interface != HIDDEN && fv.interface != HIDDEN_LIST && !fv.hidden)
			html += fv.label || capitalize(fv.name)

		var/values = vars[fv.name]

		if(islist(values))
			for(var/member in values)
				html += "<br>\n"
				html += values[member]
				html += member
		else
			html += values

		if(fv.interface == RADIO_OPTION)
			html += fv.label || fv.html_value

		html += "<br>\n"


	//? Put the submit button at the bottom.
	for(fv in form_vars)
		if(fv.interface != SUBMIT && fv.interface != RESET)
			continue

		html += vars[fv.name]

	return html
