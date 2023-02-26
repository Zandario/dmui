/// Called in DisplayForm().
/Form/proc/Initialize()
	return

/// Called when the form is complete.
/Form/proc/ProcessForm()
	return



/// Examines user-defined variables and creates list of form interface elements.
/Form/proc/MakeFormVarList(parent_form)

	var/V

	var/myvars[] = vars.Copy() // vars list is slow, so save a copy of it

	var/control_tags = list(
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

	for(V in myvars)
		var/control = findtextEx(V,"_")
		var/next_control

		while(control)
			next_control = findtextEx(V, "_", control+1)

			if(!next_control)
				break

			control = next_control


		if(control)
			control = copytext(V,control+1)

			if(control in control_tags)
				continue

			if("[text2num(control)]" == control)
				continue



		if(issaved(vars[V]) && V != "tag")
			var/FormVar/fv = new()

			fv.name = V

			if(istext(vars[V]))
				fv.input_type = TEXT_ITYPE

			else if(isnum(vars[V]))
				fv.input_type = NUM_ITYPE


			fv.size = form_default_size

			fv.maxlength = form_default_maxlen


			if(V == "submit")
				fv.interface = SUBMIT

			else if(V == "reset")
				fv.interface = RESET



			var/var_values = "[V]_values"
			if(var_values in myvars)
				fv.values = vars[var_values]



			var/var_validate = "[V]_validate"
			if(var_validate in myvars)
				fv.validate = vars[var_validate]



			var/var_maxlen = "[V]_maxlen"
			if(var_maxlen in myvars)
				fv.maxlength = vars[var_maxlen]



			var/var_size = "[V]_size"
			if(var_size in myvars)
				fv.size = vars[var_size]



			var/var_wrap = "[V]_wrap"
			if(var_wrap in myvars)
				fv.wrap = vars[var_wrap]



			var/var_extra = "[V]_extra"
			if(var_extra in myvars)
				fv.extra = vars[var_extra]



			var/var_label = "[V]_label"
			if(var_label in myvars)
				fv.label = vars[var_label]



			var/var_hidden = "[V]_hidden"
			if(var_hidden in myvars)
				fv.hidden = vars[var_hidden]



			var/n

			for(n=1, , n++)
				var/var_n = "[V]_[n]"

				if(var_n in myvars)
					fv.interface = RADIO


					var/FormVar/rv = new()

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
						if(fv.input_type == AUTO)
							fv.input_type = NUM_ITYPE

					else if(fv.input_type == NUM_ITYPE)
						fv.input_type = TEXT_ITYPE

				else
					break



			var/var_interface = "[V]_interface"

			if(var_interface in myvars)
				fv.interface = vars[var_interface]



			if(fv.interface == AUTO || fv.interface == SUB_FORM)

				var/Form/sf = vars[fv.name]

				if(istype(sf))
					//TODO: make sure prefix plus sub-form variables do not conflict with any others on this form
					sf.SetVarPrefix("[form_var_prefix][fv.name]_")

					fv.interface = SUB_FORM

				else if(fv.interface == SUB_FORM)
					world.log << "Error: [type]/var/[fv.name] must be a form object."



			if(fv.interface == AUTO || fv.interface == BUTTON || fv.interface == PROMPT)
				var/clickproc = "[fv.name]Click"

				if(hascall(src,clickproc))
					fv.clickproc = clickproc
				else
					clickproc = Capitalize(clickproc)

					if(hascall(src,clickproc))
						fv.clickproc = clickproc


			if(fv.clickproc && fv.interface == AUTO)
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



/Form/proc/SetVarPrefix(var_prefix)

	var/FormVar/fv

	form_var_prefix = var_prefix

	for(fv in form_vars)
		if(fv.interface == SUB_FORM)
			var/Form/sf = vars[fv.name]

			sf.SetVarPrefix("[form_var_prefix][fv.name]_")


/// Sets form_hidden and calls GetHtml().
/Form/proc/GetHiddenHtml(parent_form)

	form_hidden++

	var/target_form = GetHtml(parent_form)

	form_hidden--

	return target_form


/// Set up variables and call user-defined HtmlLayout().
/Form/proc/GetHtml(Form/parent_form)

	var/html

	var/body

	var/FormVar/fv

	var/submit_only = 1



	form_is_sub = (parent_form && parent_form != src) ? TRUE : FALSE



	//? Generate html code for each input variable

	for(fv in form_vars)
		fv.value = vars[fv.name]

		switch(fv.interface)

			if(RADIO_OPTION)
				fv.checked = (vars[fv.radio_name] == fv.value)

			if(BUTTON,PROMPT)
				if(form_byond_mode)
					fv.click_script = GetButtonScript(fv.name, parent_form)

				else //assume this is an upload field
					form_method = "post"

					form_enctype = "multipart/form-data"

			if(SELECT,MULTI_SELECT,CHECKLIST,RADIO_LIST,HIDDEN_LIST)
				var/var_values = "[fv.name]_values"

				if(var_values in vars)
					fv.values = vars[var_values]



		fv.html_value = html_encode(fv.value)

		vars[fv.name] = fv.MakeInputTag(src, form_var_prefix)


	if(!form_hidden)
		body = HtmlLayout() //? User generates html by inserting form variables


	//? Restore variables and tag on hidden ones

	for(fv in form_vars)
		if(fv.hidden || form_hidden)
			body += vars[fv.name]

		vars[fv.name] = fv.value


		switch(fv.interface)
			if(SUBMIT,RESET,CHECKBOX)
				//? Uhh... What? @Zandario
			else
				submit_only = 0


	if(!form_is_sub)
		//? Add the <form> wrapper.

		var/encoding

		var/method = form_method

		if(form_enctype)
			encoding = " enctype=[form_enctype]"

		if(form_byond_mode)
			//? Post does not work in Dream Seeker.
			method = "get"

		html = "<form method=[method][encoding] action='[GetSubmitUrl(form_sub_path)]' [form_extra]>\n"

		html += "<input type=hidden name=src value='[html_encode("\ref[src]")]'>\n"

		if(submit_only)
			//? Prevent solitary submit button from submitting an empty set of params (so form will be processed).
			html += "<input type=hidden name=submit value=1>\n"

		html += "[body]\n</form>"

	else
		html = body

	return html



/Form/proc/GetSubmitUrl(sub_path)

	if(form_url)
		return form_url

	var/url = "byond://"

	if(sub_path)
		url = "[url]/[sub_path]"

	return url



/// Return URL containing all form variables or specified parameters.
/Form/proc/GetSelfUrl(params, mob/U=usr, passive)

	var/FormVar/fv

	var/plist[0]

	usr = U

	if(ismob(params) && !U)
		//? Shuffle args around for backwards compatibility

		U = params

		params = null



	if(params || params == "")
		if(istext(params))
			plist = params2list(params)

		else
			plist = params

	else

		for(fv in form_vars)
			switch(fv.interface)
				if(RADIO_OPTION,BUTTON,PROMPT,SUBMIT,RESET)
					continue

			plist[fv.name] = vars[fv.name]



	plist["src"] = src

	if(!passive)
		StartWaiting()



	return html_encode("[GetSubmitUrl(form_sub_path)]?[list2params(plist)]")



/Form/proc/GetButtonScript(name, Form/parent_form)
	return {"document.location.href="[GetSelfUrl(form_var_prefix + name,form_usr,passive=1)]""}



/Form/proc/GetHtmlHead()
	if(form_title)
		return "<title>[form_title]</title>"


/// Returns form as a stand-alone document.
/Form/proc/GetHtmlDoc()

	var/head = GetHtmlHead()

	var/body = GetHtml()

	return {"\

<html>
<head>[head]</head>
<body>[body]</body>
</html>

"}


/**
 * Call this to send form to user.
 * Do everything except display the form.
 */
/Form/proc/PreDisplayForm(mob/U=usr)

	if(form_waiting)
		world.log << "Error: DisplayForm([U]) called before previous submission finished."

		form_waiting = null

		form_wait_count = 0

	usr = U

	if(!usr.client)
		//? No sense in creating form for NPC.
		return

	Initialize()


	for(var/FormVar/fv in form_vars)
		if(fv.interface == SUB_FORM)
			var/Form/sf = vars[fv.name]

			//TODO: could call sf.PreDisplayForm() here but code currently assumes lack of StartWaiting() call on sub-forms

			sf.Initialize()

	StartWaiting()


/Form/proc/DisplayForm(mob/U=usr)

	usr = U

	PreDisplayForm()

	usr << browse(GetHtmlDoc(), form_window)


/**
 * Call this to submit a filled out form.
 *
 * This is primarily used by CGI scripts on the web
 * optional params list contains the pre-parsed contents of href
 */
/Form/proc/SubmitForm(href, mob/U=usr, params)

	usr = U

	if(!form_wait_count)
		StartWaiting()

	return Topic(href,params)




/Form/proc/StartWaiting()

	form_usr = usr

	form_waiting = src //avoid garbage collector

	form_wait_count += 1



/Form/proc/StopWaiting()

	if(form_wait_count)
		form_wait_count -= 1


	if(!form_wait_count)
		if(form_reusable)
			//? Reset wait counter.
			form_wait_count = 1

		else
			form_usr = null
			form_waiting = null

		ProcessForm()



/Form/proc/Capitalize(txt)
	return uppertext(copytext(txt, 1, 2)) + copytext(txt, 2)


/**
 * Returns html text.
 *
 * The default HtmlLayout() is almost always overridden by the user.
 * It makes a very simple (and probably ugly) form interface for the given variables.
 * It does make rapid form development a breeze, though.
 */
/Form/proc/HtmlLayout()

	var/FormVar/fv

	var/html


	for(fv in form_vars)
		if(fv.hidden || form_hidden)
			continue //hidden variables are automatically inserted

		if(fv.interface == SUBMIT || fv.interface == RESET || fv.interface == RADIO)
			continue

		if(fv.interface != RADIO_OPTION && fv.interface != BUTTON && fv.interface != HIDDEN && fv.interface != HIDDEN_LIST && !fv.hidden)
			html += fv.label || Capitalize(fv.name)

		var/value = vars[fv.name]

		if(istype(value,/list))
			for(var/V in value)
				html += "<br>\n"

				html += value[V]

				html += V

		else
			html += value

		if(fv.interface == RADIO_OPTION)
			html += fv.label || fv.html_value

		html += "<br>\n"


	//Put the submit button at the bottom

	for(fv in form_vars)
		if(fv.interface != SUBMIT && fv.interface != RESET)
			continue

		html += vars[fv.name]


	return html
