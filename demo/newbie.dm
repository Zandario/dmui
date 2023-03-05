/mob/verb/NewbieForm()

	var/buoy_interface/Newbie/frm = new()

	frm.display_form(src) //? Send usr the form.

/mob/var/race //human, ogre, or jellyfish



/buoy_interface/Newbie

	var/player_name

	var/gender

	var/gender_1 = "male"
	var/gender_2 = "female"
	var/gender_3 = "neuter"

	var/race
	var/race_values = list("human","ogre","jellyfish")


/buoy_interface/Newbie/Initialize()
	player_name   = usr.name
	gender = usr.gender
	race   = usr.race


/buoy_interface/Newbie/process_form()

	usr.name = player_name

	usr.gender = gender

	usr.race = race

	usr << browse("You have been modified!")


/buoy_interface/Newbie/get_html_layout()
	return {"

Your name: [player_name] <br>
Your gender:      <br>
[gender_1] male   <br>
[gender_2] female <br>
[gender_3] other  <br>
Your race: [race] <br>

[submit]

"}
