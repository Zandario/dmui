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
/datum/dmui_var/proc/generate_input_tag(datum/dmui_form/form, var_prefix)
	var/html
	var/html_name = var_prefix + name

	if(isnull(input_type))
		if(istext(value))
			input_type = TEXT_ITYPE

		else if(isnum(value))
			input_type = NUM_ITYPE

		else if(isicon(value))
			input_type = ICON_ITYPE


	if(isnull(interface))
		if(values)
			interface = SELECT

			if(istype(value,/list))
				interface = MULTI_SELECT

		else if(input_type == ICON_ITYPE)
			interface = PROMPT_FOR_ICON

		else if(input_type == SOUND_ITYPE)
			interface = PROMPT_FOR_SOUND

		else if(input_type == FILE_ITYPE)
			interface = PROMPT_FOR_FILE

		else if(findtext(size, "x"))
			interface = TEXTAREA

		else if(istype(value, /datum/dmui_form))
			interface = SUB_FORM

		else
			interface = TEXT



	//? Some hidden elements are handled specially.

	if(hidden)
		switch(interface)
			if(HIDDEN_LIST, RADIO_OPTION, SUB_FORM)
				//? Nothing??? @Zandario

			if(CHECKBOX)
				//? This optimization also preserves boolean value at display time

				if(value)
					interface = HIDDEN

				else
					return

			if(MULTI_SELECT, CHECKLIST)
				interface = HIDDEN_LIST

			else
				interface = HIDDEN



	switch(interface)
		if(SELECT, MULTI_SELECT)

			html = "<select name=[html_name]"

			if(interface == MULTI_SELECT)
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


		if(TEXTAREA)
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


		if(TEXT, PASSWORD)
			html = "<input name=[html_name]"

			if(interface == PASSWORD)
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


		if(CHECKBOX)
			html = "<input name=[html_name] type=checkbox value=1"

			if(value)
				html += " checked"

			html += " [extra]>"


		if(RADIO_OPTION)
			html = "<input name='[radio_name]' type=radio value='[html_value]'"

			if(checked)
				html += " checked"

			html += " [extra]>"


		if(RADIO)
			return //not an interface element


		if(RESET)
			if(value && !form.form_is_sub)
				html = "<input type=reset value='[html_value]' [extra]>"

		if(SUBMIT)
			if(value && !form.form_is_sub)
				html = "<input type=submit value='[html_value]' [extra]>"

		if(BUTTON)
			if(click_script)
				html = "<input id='button' type=button value='[label || html_value || name]' onClick='[click_script]' [extra]>"

		if(PROMPT)
			if(click_script)
				html = "<input type=button value='...' onClick='[click_script]' [extra]>"

			else if(input_type == ICON_ITYPE || input_type == SOUND_ITYPE || input_type == FILE_ITYPE)
				html = "<input name=[html_name] type=file [extra]>"


		if(HIDDEN)
			html = "<input name=[html_name] type=hidden value='[html_value]' [extra]>"


		if(SUB_FORM)
			var/datum/dmui_form/sf = value

			html = sf.get_html(form)


		if(HIDDEN_LIST)
			for(var/V in value)
				html += "<input name=[html_name] value='[html_encode(V)]' type=hidden [extra]>\n"


		if(CHECKLIST)
			html = list()

			for(var/V in values)
				html[V] = "<input name=[html_name] value='[html_encode(V)]' type=checkbox[(V in value) ? " checked" : ""] [extra]>"


		if(RADIO_LIST)
			html = list()

			for(var/V in values)
				html[V] = "<input name=[html_name] value='[html_encode(V)]' type=radio[(V == value) ? " checked" : ""] [extra]>"


	return html
