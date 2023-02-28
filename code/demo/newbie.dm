/mob/verb/NewbieForm()

	var/datum/dmui_form/Newbie/frm = new()

	frm.display_form(src) //? Send usr the form.

/mob/var/race //human, ogre, or jellyfish



/datum/dmui_form/Newbie

	var/name

	var/gender

	var/gender_1 = "male"
	var/gender_2 = "female"
	var/gender_3 = "neuter"

	var/race
	var/race_values = list("human","ogre","jellyfish")


/datum/dmui_form/Newbie/Initialize()
	. = ..()

	name   = usr.name
	gender = usr.gender
	race   = usr.race


/datum/dmui_form/Newbie/process_form()

	usr.name = name

	usr.gender = gender

	usr.race = race

	usr << browse("You have been modified!")


/datum/dmui_form/Newbie/get_html_layout()
	return \
{"
Your name: [name]
<br>Your gender:
<br>[gender_1] male
<br>[gender_2] female
<br>[gender_3] other
<br>Your race: [race]
<br>
[submit]
"}
