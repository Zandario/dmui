/buoy_component
	abstract_type = /buoy_component
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
	var/buoy_interface/our_form

/// Generate the html for an input variable.
/buoy_component/proc/Initialize(buoy_interface/form, var_prefix, ...)
	var/html_name = var_prefix + name

	if(isnull(input_type))
		if(istext(value))
			input_type = TEXT_ITYPE

		else if(isnum(value))
			input_type = NUM_ITYPE

		else if(isicon(value))
			input_type = ICON_ITYPE


	if(isnull(interface))
		auto_generate_interface()


	//? Some hidden elements are handled specially.
	if(hidden || form.form_hidden)
		handle_hidden()

	return handle_interface(form, html_name)


/buoy_component/proc/auto_generate_interface()
	if(!isnull(interface))
		return // wtf dude. //TODO: stack_trace

	if(values)
		interface = SELECT

		if(istype(value,/list))
			interface = MULTI_SELECT

	else if(findtext(size, "x"))
		interface = TEXTAREA

	else if(istype(value, /buoy_interface))
		interface = SUB_FORM

	else switch(input_type)
		if(ICON_ITYPE)
			interface = PROMPT_FOR_ICON

		if(SOUND_ITYPE)
			interface = PROMPT_FOR_SOUND

		if(FILE_ITYPE)
			interface = PROMPT_FOR_FILE
		else
			interface = TEXT


/buoy_component/proc/handle_hidden()
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



/buoy_component/proc/handle_interface(buoy_interface/form, html_name)
	switch(interface)
		if(SELECT, MULTI_SELECT)

			. = "<select name=[html_name]"

			if(interface == MULTI_SELECT)
				. += " multiple"

			. += ">"

			var/V

			for(V in values)
				var/optval = html_encode(V)

				. += "<option"

				if(V == value || (V in value))
					. += " selected"

				. += " value='[optval]'>[optval]\n"

			. += "</select>"


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

			. += "<textarea name=[html_name] [row_col][wrap_html]>[html_value]</textarea>"


		if(TEXT, PASSWORD)
			. = "<input name=[html_name]"

			if(interface == PASSWORD)
				. += " type=password"

			else
				. += " type=text"

			if(value)
				. += " value='[html_value]'"

			if(size)
				. += " size='[size]'"

			if(maxlength)
				. += " maxlength='[maxlength]'"

			. += " [extra]>"


		if(CHECKBOX)
			. = "<input name=[html_name] type=checkbox value=1"

			if(value)
				. += " checked"

			. += " [extra]>"


		if(RADIO_OPTION)
			. = "<input name='[radio_name]' type=radio value='[html_value]'"

			if(checked)
				. += " checked"

			. += " [extra]>"


		if(RADIO)
			return //not an interface element


		if(RESET)
			if(value && !form.form_is_sub)
				. = "<input type=reset value='[html_value]' [extra]>"

		if(SUBMIT)
			if(value && !form.form_is_sub)
				. = "<input type=submit value='[html_value]' [extra]>"

		if(BUTTON)
			if(click_script)
				. = "<input id='button' type=button value='[label || html_value || name]' onClick='[click_script]' [extra]>"

		if(PROMPT)
			if(click_script)
				. = "<input type=button value='...' onClick='[click_script]' [extra]>"

			else if(input_type == ICON_ITYPE || input_type == SOUND_ITYPE || input_type == FILE_ITYPE)
				. = "<input name=[html_name] type=file [extra]>"


		if(HIDDEN)
			. = "<input name=[html_name] type=hidden value='[html_value]' [extra]>"


		if(SUB_FORM)
			var/buoy_interface/sf = value

			if(hidden || form.form_hidden)
				. = sf.get_hidden_html(form)

			else
				. = sf.get_html(form)


		if(HIDDEN_LIST)
			for(var/V in value)
				. += "<input name=[html_name] value='[html_encode(V)]' type=hidden [extra]>\n"


		if(CHECKLIST)
			. = list()

			for(var/V in values)
				.[V] = "<input name=[html_name] value='[html_encode(V)]' type=checkbox[(V in value) ? " checked" : ""] [extra]>"


		if(RADIO_LIST)
			. = list()

			for(var/V in values)
				.[V] = "<input name=[html_name] value='[html_encode(V)]' type=radio[(V == value) ? " checked" : ""] [extra]>"
