/mob/verb/themed_example()

	var/datum/dmui_form/disposal_bin/new_form = new(src)

	new_form.display_form(src) //? Send usr the form.


/datum/dmui_form/disposal_bin
	form_title  = "Disposal Bin"
	window_size = "330x190"
	window_param_flags = DMUI_CANNOT_RESIZE | DMUI_CANNOT_MINIMIZE | DMUI_CANNOT_MAXIMIZE | DMUI_CANNOT_SCROLL

	var/pressure
	var/full_pressure

	var/flush
	var/flush_interface = BUTTON

	var/eject
	var/eject_interface = BUTTON

	var/pressure_charging
	var/pressure_charging_interface = BUTTON

/datum/dmui_form/disposal_bin/Initialize()
	pressure = rand(0, 100)
	full_pressure = pressure >= 100
	return ..()


/datum/dmui_form/disposal_bin/get_html_header()
	. = ..()
	. += "<style>[file2text('html/dmui-nano-common.css')]</style>"


/// Returns form as a stand-alone document.
/datum/dmui_form/disposal_bin/get_html_body()
	var/head = get_html_header()
	var/body = get_html()

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

/datum/dmui_form/disposal_bin/get_html_layout()
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

/datum/dmui_form/disposal_bin/proc/flushClick()
	user << output("You flushed!")

/datum/dmui_form/disposal_bin/proc/ejectClick()
	user << output("You ejected!") // Suspicious.

/datum/dmui_form/disposal_bin/proc/pressure_chargingClick()
	user << output("You pressed pressure_charging!")
