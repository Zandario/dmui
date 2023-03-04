
/buoy_form

	var/submit = "Submit"
	var/reset  = "Reset"

	/// Where to send form for processing.
	var/tmp/form_url

	/// Extra path info after the name of this .dmb
	var/tmp/form_sub_path

	/// Title of the form.
	var/tmp/form_title

	/// TODO: dmui_window
	/// The ID of the skin window used.
	var/tmp/window_key

	var/tmp/fancy_window = FALSE
	var/tmp/can_resize   = TRUE
	var/tmp/can_scroll   = TRUE
	var/tmp/can_minimize = TRUE

	/// User may submit this form multiple times.
	var/tmp/form_reusable = FALSE

	/// Web browser submission method (must be "get" in BYOND mode).
	var/tmp/form_method = "get"

	/// Extra html code to insert into the form tag.
	var/tmp/form_extra

	var/tmp/form_width  = 512
	var/tmp/form_height = 512

	//# internal stuff (no peeking)

	/// List of user-defined form variables.
	var/tmp/buoy_element/form_vars[0]

	/// The mob who opened/is using the UI.
	var/tmp/mob/user

	/// Doubles as a self-reference to prevent auto-deletion by garbage collector.
	var/tmp/form_waiting

	/// Number of incomplete operations.
	var/tmp/form_wait_count

	/// Uses application/x-www-form-urlencoded by default (file uploads will switch it to multipart/form-data).
	var/tmp/form_enctype

	/// False for web clients.
	var/tmp/form_byond_mode = TRUE

	var/tmp/form_default_size

	var/tmp/form_default_maxlen

	/// Prefix to use for html form variables.
	var/tmp/form_var_prefix

	/// True if this is a sub-form.
	var/tmp/form_is_sub = FALSE

	/// Hides the entire form (used by get_hidden_html()).
	var/tmp/form_hidden






/buoy_form/New()
	generate_elements()
	return ..()




/buoy_form/Topic(href, params[])
	if(usr != user)
		world.log << "Illegal form call by ([usr],[type])."

		return //? Do not do normal wrapup.

	if(!form_sub_path)
		if(form_byond_mode)
			if(findtext(href, "/", 1, 2))
				var/qry = findtext(href, "?")

				form_sub_path = copytext(href, 2, qry)


	var/buoy_element/fv

	for(fv in form_vars)
		var/html_name = form_var_prefix + fv.name



		if(html_name in params)
			var/val = params[html_name]

			if(fv.interface == MULTI_SELECT || fv.interface == CHECKLIST || fv.interface == HIDDEN_LIST)
				if(!istype(val,/list))
					val = list(val)

				var/lst[] = val

				if(fv.input_type == NUM_ITYPE)
					for(var/i=1,i<=lst.len,i++)
						lst[i] = text2num(lst[i])

				for(var/i=1,i<=lst.len,i++)
					if(!(lst[i] in fv.values))
						if(fv.input_type != NUM_ITYPE && (text2num(lst[i]) in fv.values))
							lst[i] = text2num(lst[i])

						else if(fv.validate)
							world.log << "Illegal value for [fv.name] from ([usr]): ([href])."

							goto wrapup

			else

				if(fv.input_type == NUM_ITYPE)
					val = text2num(val)

				if(fv.values && !(val in fv.values))
					if(fv.input_type != NUM_ITYPE && (text2num(val) in fv.values))
						//? Only some values are numeric, and this is one of them.
						val = text2num(val)

					else if(fv.validate)
						world.log << "Illegal value for [fv.name] from ([usr]): ([href])."

						goto wrapup

			switch(fv.interface)
				if(SUBMIT)
					//ignore -- bogus submit value is used to force processing of empty forms

				if(RADIO_OPTION,RESET) //these should never get set
					world.log << "Illegal form input from ([usr]): ([href])."
					goto wrapup

				if(BUTTON) //only happens when button is clicked--not when form is submitted
					start_waiting()

					call(src, fv.clickproc)()

					stop_waiting()

					return BUTTON_CLICK

				if(PROMPT)
					if(form_byond_mode)
						start_waiting()

						switch(fv.input_type)
							if(ICON_ITYPE)
								var/pval = (input(usr,fv.label || fv.name) as icon|null)

								if(!pval && vars[fv.name] && alert("Retain previous setting?",,"Yes","No") == "Yes")
									pval = vars[fv.name]

								vars[fv.name] = pval

							if(SOUND_ITYPE)
								var/pval = (input(usr,fv.label || fv.name) as sound|null)

								if(!pval && vars[fv.name] && alert("Retain previous setting?",,"Yes","No") == "Yes")
									pval = vars[fv.name]

								vars[fv.name] = pval

							if(FILE_ITYPE)
								var/pval = (input(usr,fv.label || fv.name) as file|null)

								if(!pval && vars[fv.name] && alert("Retain previous setting?",,"Yes","No") == "Yes")
									pval = vars[fv.name]

								vars[fv.name] = pval

							else
								vars[fv.name] = call(src, fv.clickproc)()

						stop_waiting()

						return BUTTON_CLICK


			if(fv.input_type == ICON_ITYPE || fv.input_type == SOUND_ITYPE || fv.input_type == FILE_ITYPE)
				if(findtext(val,"\[") == 1)
					val = locate(val)

				//TODO: check file type


			vars[fv.name] = val


		else //? No value was submitted.
			switch(fv.interface)
				if(CHECKBOX)
					vars[fv.name] = null



	//? Do sub-forms.

	for(fv in form_vars)
		if(fv.interface == SUB_FORM)
			var/buoy_form/sf = vars[fv.name]

			var/ret = sf.submit_form(href,usr,params)

			if(ret == BUTTON_CLICK)
				return ret

	wrapup:

	stop_waiting()

	return SUBMIT_CLICK
