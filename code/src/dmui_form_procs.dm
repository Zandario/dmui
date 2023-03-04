/// Called in display_form().
/buoy_form/proc/Initialize()
	return

/// Called when the form is complete.
/buoy_form/proc/process_form()
	return

/// Examines user-defined variables and creates list of form interface elements.
/buoy_form/proc/generate_elements(parent_form)

	var/myvars[] = vars.Copy() // vars list is slow, so save a copy of it

	var/list/control_tags = list(
		"values"    = 1,
		"validate"  = 1,
		"maxlen"    = 1,
		"size"      = 1,
		"wrap"      = 1,
		"extra"     = 1,
		"label"     = 1,
		"hidden"    = 1,
		"interface" = 1,
	)

	for(var/variable in myvars)
		var/control = findtextEx(variable, "_")
		var/next_control

		while(control)
			next_control = findtextEx(variable, "_", control+1)

			if(!next_control)
				break

			control = next_control

		if(control)
			control = copytext(variable, control+1)

			if(control in control_tags)
				continue

			if("[text2num(control)]" == control)
				continue

		if(issaved(vars[variable]) && variable != "tag")
			var/buoy_element/fv = new()

			fv.name = variable

			if(istext(vars[variable]))
				fv.input_type = TEXT_ITYPE

			else if(isnum(vars[variable]))
				fv.input_type = NUM_ITYPE


			fv.size = form_default_size

			fv.maxlength = form_default_maxlen


			if(variable == "submit")
				fv.interface = SUBMIT

			else if(variable == "reset")
				fv.interface = RESET



			var/var_values = "[variable]_values"
			if(var_values in myvars)
				fv.values = vars[var_values]



			var/var_validate = "[variable]_validate"
			if(var_validate in myvars)
				fv.validate = vars[var_validate]



			var/var_maxlen = "[variable]_maxlen"
			if(var_maxlen in myvars)
				fv.maxlength = vars[var_maxlen]



			var/var_size = "[variable]_size"
			if(var_size in myvars)
				fv.size = vars[var_size]



			var/var_wrap = "[variable]_wrap"
			if(var_wrap in myvars)
				fv.wrap = vars[var_wrap]



			var/var_extra = "[variable]_extra"
			if(var_extra in myvars)
				fv.extra = vars[var_extra]



			var/var_label = "[variable]_label"
			if(var_label in myvars)
				fv.label = vars[var_label]



			var/var_hidden = "[variable]_hidden"
			if(var_hidden in myvars)
				fv.hidden = vars[var_hidden]



			var/n

			for(n=1, , n++)
				var/var_n = "[variable]_[n]"

				if(var_n in myvars)
					fv.interface = RADIO


					var/buoy_element/rv = new()

					rv.interface = RADIO_OPTION

					rv.name = var_n

					rv.radio_name = fv.name

					rv.value = (vars[var_n] || n)

					form_vars += rv


					var/var_n_label = "[var_n]_label"

					if(var_n_label in myvars)
						rv.label = vars[var_n_label]



					if(!fv.values)
						fv.values = list(rv.value)
					else
						fv.values += rv.value

					if(isnum(rv.value))
						if(isnull(fv.input_type))
							fv.input_type = NUM_ITYPE

					else if(fv.input_type == NUM_ITYPE)
						fv.input_type = TEXT_ITYPE

				else
					break



			var/var_interface = "[variable]_interface"

			if(var_interface in myvars)
				fv.interface = vars[var_interface]



			if(isnull(fv.interface) || fv.interface == SUB_FORM)

				var/buoy_form/sf = vars[fv.name]

				if(istype(sf))
					//TODO: make sure prefix plus sub-form variables do not conflict with any others on this form
					sf.set_var_prefix("[form_var_prefix][fv.name]_")

					fv.interface = SUB_FORM

				else if(fv.interface == SUB_FORM)
					world.log << "Error: [type]/var/[fv.name] must be a form object."



			if(isnull(fv.interface) || fv.interface == BUTTON || fv.interface == PROMPT)
				var/clickproc = "[fv.name]Click"

				if(hascall(src, clickproc))
					fv.clickproc = clickproc
				else
					clickproc = capitalize(clickproc)

					if(hascall(src, clickproc))
						fv.clickproc = clickproc


			if(fv.clickproc && isnull(fv.interface))
				fv.interface = BUTTON


			if(fv.interface == PROMPT_FOR_ICON)
				fv.interface  = PROMPT
				fv.input_type = ICON_ITYPE

			else if(fv.interface == PROMPT_FOR_SOUND)
				fv.interface  = PROMPT
				fv.input_type = SOUND_ITYPE

			else if(fv.interface == PROMPT_FOR_FILE)
				fv.interface  = PROMPT
				fv.input_type = FILE_ITYPE

			else if(fv.interface == PROMPT && !fv.clickproc)
				world.log << "Error: [type]/var/[fv.name] needs a Click() proc or an input type."

			else if(fv.interface == BUTTON && !fv.clickproc)
				world.log << "Error: [type]/var/[fv.name] needs a Click() proc."


			form_vars += fv



/buoy_form/proc/set_var_prefix(var_prefix)

	form_var_prefix = var_prefix

	for(var/buoy_element/our_var as anything in form_vars) // Ah yes, vars in vars
		if(our_var.interface == SUB_FORM)
			var/buoy_form/sub_form = vars[our_var.name]

			sub_form.set_var_prefix("[form_var_prefix][our_var.name]_")


/// Sets form_hidden and calls get_html().
/buoy_form/proc/get_hidden_html(parent_form)
	form_hidden++
	var/target_form = get_html(parent_form)
	form_hidden--

	return target_form


/// Set up variables and call user-defined get_html_layout().
/buoy_form/proc/get_html(buoy_form/parent_form)

	var/html
	var/body
	var/buoy_element/fv
	var/submit_only = TRUE

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

		vars[fv.name] = fv.Initialize(src, form_var_prefix)

	if(!form_hidden)
		//? User generates html by inserting form variables.
		body = get_html_layout()

	//? Restore variables and tag on hidden ones
	for(fv in form_vars)
		if(fv.hidden || form_hidden)
			body += vars[fv.name]

		vars[fv.name] = fv.value

		switch(fv.interface)
			if(SUBMIT,RESET,CHECKBOX)
			else
				submit_only = FALSE

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

		if(submit_only)
			//? Prevent solitary submit button from submitting an empty set of params (so form will be processed).
			html += "<input type=hidden name=submit value=1>\n"
		html += "[body]\n</form>"
	else
		html = body

	return html


/buoy_form/proc/get_submit_url(sub_path)
	if(form_url)
		return form_url

	var/url = "byond://"
	if(sub_path)
		url = "[url]/[sub_path]"

	return url


/// Return URL containing all form variables or specified parameters.
/buoy_form/proc/get_self_url(params, mob/user, passive)


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
		for(var/buoy_element/our_var as anything in form_vars)
			switch(our_var.interface)
				if(RADIO_OPTION,BUTTON,PROMPT,SUBMIT,RESET)
					continue

			plist[our_var.name] = vars[our_var.name]

	plist["src"] = src

	if(!passive)
		start_waiting()

	return html_encode("[get_submit_url(form_sub_path)]?[list2params(plist)]")


/buoy_form/proc/get_button_script(name, buoy_form/parent_form)
	return {"document.location.href="[get_self_url(form_var_prefix + name, user, passive=TRUE)]""}


/buoy_form/proc/get_html_header()
	if(form_title)
		return "<title>[form_title]</title>"


/// Returns form as a stand-alone document.
/buoy_form/proc/get_html_body()
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
/buoy_form/proc/setup_form(mob/user)
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

	for(var/buoy_element/our_var as anything in form_vars)
		if(our_var.interface == SUB_FORM)
			var/buoy_form/sub_form = vars[our_var.name]
			//TODO: could call sub_form.setup_form() here but code currently assumes lack of start_waiting() call on sub-forms
			sub_form.Initialize()

	start_waiting()


/buoy_form/proc/display_form(mob/user)
	setup_form(user)
	var/compiled_args = "window=[window_key];size=[form_width]x[form_height];titlebar=[!fancy_window];can_resize=[can_resize];can_scroll=[can_scroll];can_minimize=[can_minimize];"
	user << browse(get_html_body(), compiled_args)
	user << output(compiled_args)

	#ifdef DMUI_VERBOSE_LOGGING
	user << output(html_encode("[get_html_body()]"))
	#endif


/**
 * Call this to submit a filled out form.
 *
 * This is primarily used by CGI scripts on the web
 * optional params list contains the pre-parsed contents of href
 */
/buoy_form/proc/submit_form(href, mob/user, params)
	if(!form_wait_count)
		start_waiting()

	return Topic(href, params)


/buoy_form/proc/start_waiting()
	if(isnull(user))
		world.log << "Error: start_waiting() called without a user."
		return
	form_waiting = src //avoid garbage collector
	form_wait_count += 1


/buoy_form/proc/stop_waiting()
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


/buoy_form/proc/capitalize(txt)
	return uppertext(copytext(txt, 1, 2)) + copytext(txt, 2)


/**
 * Returns html text.
 *
 * The default get_html_layout() is almost always overridden by the user.
 * It makes a very simple (and probably ugly) form interface for the given variables.
 * It does make rapid form development a breeze, though.
 */
/buoy_form/proc/get_html_layout()
	var/buoy_element/fv
	var/html

	for(fv in form_vars)
		if(fv.hidden || form_hidden)
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
