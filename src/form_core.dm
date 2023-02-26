/Form

	var/submit = "Submit"

	var/reset  = "Reset"

	/// Where to send form for processing.
	var/tmp/form_url

	/// Extra path info after the name of this .dmb
	var/tmp/form_sub_path

	var/tmp/form_title

	/// browse() parameters to use for forms in DreamSeeker.
	var/tmp/form_window

	/// User may submit this form multiple times.
	var/tmp/form_reusable

	/// True if form submission is handled by client.CGI (which creates a new instance of the form to process the results).
	var/tmp/form_cgi_mode

	/// Web browser submission method (must be "get" in BYOND mode).
	var/tmp/form_method = "get"

	/// Extra html code to insert into the form tag.
	var/tmp/form_extra



	//# internal stuff (no peeking)

	/// List of user-defined form variables.
	var/tmp/FormVar/form_vars[0]

	var/tmp/mob/form_usr

	/// Doubles as a self-reference to prevent auto-deletion by garbage collector.
	var/tmp/form_waiting

	/// Number of incomplete operations.
	var/tmp/form_wait_count

	/// Uses application/x-www-form-urlencoded by default (file uploads will switch it to multipart/form-data).
	var/tmp/form_enctype

	/// False for web clients.
	var/tmp/form_byond_mode = 1

	var/tmp/form_default_size

	var/tmp/form_default_maxlen

	/// Prefix to use for html form variables.
	var/tmp/form_var_prefix

	/// True if this is a sub-form.
	var/tmp/form_is_sub

	/// Hides the entire form (used by GetHiddenHtml()).
	var/tmp/form_hidden


	//# Constants

	var/const/AUTO = null


	//# Input types

	var/const/TEXT_ITYPE  = 1
	var/const/NUM_ITYPE   = 2
	var/const/ICON_ITYPE  = 3
	var/const/SOUND_ITYPE = 4
	var/const/FILE_ITYPE  = 5


	//# Interface elements

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



/Form/New()
	MakeFormVarList()
	return ..()




/Form/Topic(href,params[])
	if(usr != form_usr)
		world.log << "Illegal form call by ([usr],[type])."

		return //do not do normal wrapup

	if(!form_sub_path)
		if(form_byond_mode)
			if(findtext(href,"/",1,2))
				var/qry = findtext(href,"?")

				form_sub_path = copytext(href,2,qry)


	var/FormVar/fv

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

					call(src,fv.clickproc)()

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
								vars[fv.name] = call(src,fv.clickproc)()

						StopWaiting()

						return BUTTON_CLICK


			if(fv.input_type == ICON_ITYPE || fv.input_type == SOUND_ITYPE || fv.input_type == FILE_ITYPE)
				if(findtext(val,"\[") == 1)
					val = locate(val)

				//TODO: check file type


			vars[fv.name] = val


		else //no value submitted
			switch(fv.interface)
				if(CHECKBOX)
					vars[fv.name] = null



	//do sub-forms

	for(fv in form_vars)
		if(fv.interface == SUB_FORM)
			var/Form/sf = vars[fv.name]

			var/ret = sf.SubmitForm(href,usr,params)

			if(ret == BUTTON_CLICK)
				return ret

	wrapup:

	StopWaiting()

	return SUBMIT_CLICK
