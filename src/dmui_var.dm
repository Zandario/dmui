/datum/dmui_var
	var/name
	var/value
	var/html_value
	var/label
	var/checked
	var/radio_name
	var/input_type
	var/interface
	var/hidden
	var/maxlength
	var/size
	var/wrap
	var/extra
	var/values[]
	var/validate = TRUE
	var/clickproc
	var/click_script
	var/datum/dmui_form/our_form

/// Generate the html for an input variable.
/datum/dmui_var/proc/MakeInputTag(datum/dmui_form/form, var_prefix)
	var/html
	var/html_name = var_prefix + name

	if(input_type == our_form.AUTO)
		if(istext(value))
			input_type = our_form.TEXT_ITYPE

		else if(isnum(value))
			input_type = our_form.NUM_ITYPE

		else if(isicon(value))
			input_type = our_form.ICON_ITYPE


	if(interface == our_form.AUTO)
		if(values)
			interface = our_form.SELECT

			if(istype(value,/list))
				interface = our_form.MULTI_SELECT

		else if(input_type == our_form.ICON_ITYPE)
			interface = our_form.PROMPT_FOR_ICON

		else if(input_type == our_form.SOUND_ITYPE)
			interface = our_form.PROMPT_FOR_SOUND

		else if(input_type == our_form.FILE_ITYPE)
			interface = our_form.PROMPT_FOR_FILE

		else if(findtext(size, "x"))
			interface = our_form.TEXTAREA

		else if(istype(value, /datum/dmui_form))
			interface = our_form.SUB_FORM

		else
			interface = our_form.TEXT



	//some hidden elements are handled specially

	if(hidden || form.form_hidden)
		switch(interface)
			if(our_form.HIDDEN_LIST,our_form.RADIO_OPTION,our_form.SUB_FORM)
				//? Nothing??? @Zandario

			if(our_form.CHECKBOX)
				//? This optimization also preserves boolean value at display time

				if(value)
					interface = our_form.HIDDEN

				else
					return

			if(our_form.MULTI_SELECT,our_form.CHECKLIST)
				interface = our_form.HIDDEN_LIST

			else
				interface = our_form.HIDDEN



	switch(interface)
		if(our_form.SELECT,our_form.MULTI_SELECT)

			html = "<select name=[html_name]"

			if(interface == our_form.MULTI_SELECT)
				html += " multiple"

			html += ">"

			var/V

			for(V in values)
				var/optval = html_encode(V)

				html += "<option"

				if(V == value || (V in value))
					html += " selected"

				html += " value='[optval]'>[optval]\n"

			html += "</select>"


		if(our_form.TEXTAREA)
			var/row_col

			var/wrap_html

			if(size)
				var/xpos = istext(size) ? findtext(size,"x") : 0

				if(!xpos)
					row_col = " rows='[size]'"

				else
					row_col = " cols='[copytext(size,1,xpos)]' rows='[copytext(size,xpos+1)]'"

			if(wrap)
				wrap_html = " wrap='[wrap]'"

			html += "<textarea name=[html_name] [row_col][wrap_html]>[html_value]</textarea>"


		if(our_form.TEXT,our_form.PASSWORD)
			html = "<input name=[html_name]"

			if(interface == our_form.PASSWORD)
				html += " type=password"

			else
				html += " type=text"

			if(value)
				html += " value='[html_value]'"

			if(size)
				html += " size='[size]'"

			if(maxlength)
				html += " maxlength='[maxlength]'"

			html += " [extra]>"


		if(our_form.CHECKBOX)
			html = "<input name=[html_name] type=checkbox value=1"

			if(value)
				html += " checked"

			html += " [extra]>"


		if(our_form.RADIO_OPTION)
			html = "<input name='[radio_name]' type=radio value='[html_value]'"

			if(checked)
				html += " checked"

			html += " [extra]>"


		if(our_form.RADIO)
			return //not an interface element


		if(our_form.RESET)
			if(value && !form.form_is_sub)
				html = "<input type=reset value='[html_value]' [extra]>"

		if(our_form.SUBMIT)
			if(value && !form.form_is_sub)
				html = "<input type=submit value='[html_value]' [extra]>"

		if(our_form.BUTTON)
			if(click_script)
				html = "<input type=button value='[label || html_value || name]' onClick='[click_script]' [extra]>"

			else
				world.log << "htmllib.dm: ([name]) buttons do not work in web mode"

		if(our_form.PROMPT)
			if(click_script)
				html = "<input type=button value='...' onClick='[click_script]' [extra]>"

			else if(input_type == our_form.ICON_ITYPE || input_type == our_form.SOUND_ITYPE || input_type == our_form.FILE_ITYPE)
				html = "<input name=[html_name] type=file [extra]>"

			else
				world.log << "htmllib.dm: ([name]) buttons do not work in web mode"


		if(our_form.HIDDEN)
			html = "<input name=[html_name] type=hidden value='[html_value]' [extra]>"


		if(our_form.SUB_FORM)
			var/datum/dmui_form/sf = value

			if(hidden || form.form_hidden)
				html = sf.GetHiddenHtml(form)

			else
				html = sf.GetHtml(form)


		if(our_form.HIDDEN_LIST)
			for(var/V in value)
				html += "<input name=[html_name] value='[html_encode(V)]' type=hidden [extra]>\n"


		if(our_form.CHECKLIST)
			html = list()

			for(var/V in values)
				html[V] = "<input name=[html_name] value='[html_encode(V)]' type=checkbox[(V in value) ? " checked" : ""] [extra]>"


		if(our_form.RADIO_LIST)
			html = list()

			for(var/V in values)
				html[V] = "<input name=[html_name] value='[html_encode(V)]' type=radio[(V == value) ? " checked" : ""] [extra]>"


	return html
