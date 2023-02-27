/mob/verb/ThemedForm()

	var/datum/dmui_form/Themed/new_form = new()

	new_form.DisplayForm(src) //? Send usr the form.


/datum/dmui_form/Themed
	form_title = "Disposal Bin"
	form_width  = 330
	form_height = 190
	can_scroll  = FALSE
	can_resize  = FALSE
	// fancy_window = TRUE

	var/pressure
	var/full_pressure

	var/gender

	var/gender_1 = "male"
	var/gender_2 = "female"
	var/gender_3 = "neuter"

	var/flush
	var/flush_interface = BUTTON

	var/eject
	var/eject_interface = BUTTON

	var/pressure_charging
	var/pressure_charging_interface = BUTTON

/datum/dmui_form/Themed/Initialize()
	pressure = rand(0, 100)
	full_pressure = pressure >= 100
	return ..()


/datum/dmui_form/Themed/GetHtmlHead()
	var/html_head = ""
	html_head += "<style>[file2text('html/dmui-nano-common.css')]</style>"
	if(form_title)
		html_head += "<title>[form_title]</title>"
	return html_head

/// Returns form as a stand-alone document.
/datum/dmui_form/Themed/GetHtmlDoc()
	var/head = GetHtmlHead()
	var/body = GetHtml()

	return {"\
<!DOCTYPE html>
<html>
	<meta charset='utf-8'>
	<meta http-equiv='X-UA-Compatible' content='IE=edge'>
	<meta http-equiv='content-language' content='en-us' />
	<head>
		<title>[form_title]</title>
		<link rel="stylesheet" type="text/css" href="sui-nano-common.css">
		[head]
	</head>
	<body>
		<div class='uiWrapper'>
			<div class='uiTitleWrapper'><div class='uiTitle'><tt>[form_title]</tt></div></div>
			<div class='uiContent' id='maincontent'>
				[body]
			</div>
		</div>
	</body>
</html>

"}

/datum/dmui_form/Themed/HtmlLayout()
	var/per = full_pressure ? 100 : pressure
	return {"
<div class='display'>
	<section>
		<span class='label'>State:</span>
		<div class='content'>[full_pressure ? "Ready" : (pressure_charging ? "Pressurizing" : "Off")]</div>
	</section>
	<section>
		<span class='label'>Pressure:</span>
		<div class='content'>
			<div class='progressBar'>
				<div class='progressFill' style="width: [per]"></div>
				<div class='progressLabel'>[round(per, 1)]%</div>
			</div>
		</div>
	</section>
	<section>
		<span class='label'>Handle:</span>
		<div class='content' id="contents">[flush]</div>
	</section>
	<section>
		<span class='label'>Eject:</span>
		<div class='content' id="contents">[eject]</div>
	</section>
	<section>
		<span class='label'>Compressor:</span>
		<div class='content' id="pressure_charging">[pressure_charging]</div>
	</section>
</div>

"}

/datum/dmui_form/Themed/proc/flushClick()
	user << output("You flushed!")

/datum/dmui_form/Themed/proc/ejectClick()
	user << output("You ejected!")

/datum/dmui_form/Themed/proc/pressure_chargingClick()
	user << output("You pressed pressure_charging!")
