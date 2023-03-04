/mob/verb/KitchenForm()

	var/buoy_form/Kitchen/form = new()

	form.display_form(src) //? Send usr the form.

/buoy_form/Kitchen

	var/text
	var/text_interface = TEXT
	var/password
	var/password_interface = PASSWORD
	var/textarea
	var/textarea_interface = TEXTAREA
	var/select
	var/select_interface = SELECT
	var/multi_select
	var/multi_select_interface = MULTI_SELECT
	var/checkbox
	var/checkbox_interface = CHECKBOX
	var/radio
	var/radio_interface = RADIO
	var/radio_list
	var/radio_list_interface = RADIO_LIST
	var/hidden
	var/hidden_interface = HIDDEN
	// var/button
	// var/button_interface = BUTTON
	// var/prompt
	// var/prompt_interface = PROMPT
	var/prompt_for_icon
	var/prompt_for_icon_interface = PROMPT_FOR_ICON
	var/prompt_for_sound
	var/prompt_for_sound_interface = PROMPT_FOR_SOUND
	var/prompt_for_file
	var/prompt_for_file_interface = PROMPT_FOR_FILE
	// var/sub_form
	// var/sub_form_interface = SUB_FORM
