/**
 *
 * HTML Library
 *
 * Version: 2.0   (2023-02-26) // Restructure by Zandario
 *
 * Version: 1.9   (2023-02-26) // Modern Formatting by Zandario
 *
 * Version: 1.8   (2003-01-29)
 *
 * Version: 1.7   (2002-03-12)
 *
 * Version: 1.6   (2002-02-05)
 *
 * Version: 1.5   (2001-11-02)
 *
 * Version: 1.4   (2001-03-24)
 *
 * Version: 1.3   (2001-01-30)
 *
 * Version: 1.2   (2001-01-18)
 *
 * Version: 1.1   (2000-10-11)
 *
 * Version: 1.0   (2000-09-16)
 *
 *
 *
 * To create a new type of form, you derive one from the base Form object.
 *
 * The variables you define are automatically written to and read from the form.
 *
 * To define how the form looks, you override HtmlLayout().
 *
 *
 * See `htmllib.html` for the details.
 *
 */
/datum/dmui_form

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
	var/tmp/datum/dmui_var/form_vars[0]

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

	/// Hides the entire form (used by GetHiddenHtml()).
	var/tmp/form_hidden


	//# Constants
	var/const/AUTO = null


	//## Input types
	var/const/TEXT_ITYPE  = 1
	var/const/NUM_ITYPE   = 2
	var/const/ICON_ITYPE  = 3
	var/const/SOUND_ITYPE = 4
	var/const/FILE_ITYPE  = 5


	//## Interface elements
	var/const/TEXT             = 1
	var/const/PASSWORD         = 2
	var/const/SELECT           = 3
	var/const/MULTI_SELECT     = 4
	var/const/CHECKBOX         = 5
	var/const/RADIO            = 6  //! Variable that holds value of selected RADIO_OPTION.
	var/const/RADIO_OPTION     = 7  //! Enumerated control variables _1, _2, _3, etc.
	var/const/TEXTAREA         = 8  //! Input size is "[cols]x[rows]" or just rows.
	var/const/HIDDEN           = 9
	var/const/SUBMIT           = 10
	var/const/RESET            = 11
	var/const/BUTTON           = 12
	var/const/PROMPT           = 13
	var/const/PROMPT_FOR_ICON  = 14 //! Converts to PROMPT interface with ICON_ITYPE.
	var/const/PROMPT_FOR_SOUND = 15 //! Converts to PROMPT interface with SOUND_ITYPE.
	var/const/PROMPT_FOR_FILE  = 16 //! Converts to PROMPT interface with FILE_ITYPE.
	var/const/SUB_FORM         = 17 //! Form object or list of them.
	var/const/CHECKLIST        = 18 //! List of checkboxes (produces a list of items and their associated html at display time).
	var/const/RADIO_LIST       = 19
	var/const/HIDDEN_LIST      = 20

	var/const/SUBMIT_CLICK = 1
	var/const/BUTTON_CLICK = 2

	var/const/NO_WRAP   = "off"
	var/const/HARD_WRAP = "hard"
	var/const/SOFT_WRAP = "soft"



/datum/dmui_form/New()
	MakeFormVarList()
	return ..()




/datum/dmui_form/Topic(href, params[])
	if(usr != user)
		world.log << "Illegal form call by ([usr],[type])."

		return //? Do not do normal wrapup.

	if(!form_sub_path)
		if(form_byond_mode)
			if(findtext(href, "/", 1, 2))
				var/qry = findtext(href, "?")

				form_sub_path = copytext(href, 2, qry)


	var/datum/dmui_var/fv

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
					StartWaiting()

					call(src, fv.clickproc)()

					StopWaiting()

					return BUTTON_CLICK

				if(PROMPT)
					if(form_byond_mode)
						StartWaiting()

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

						StopWaiting()

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
			var/datum/dmui_form/sf = vars[fv.name]

			var/ret = sf.SubmitForm(href,usr,params)

			if(ret == BUTTON_CLICK)
				return ret

	wrapup:

	StopWaiting()

	return SUBMIT_CLICK
