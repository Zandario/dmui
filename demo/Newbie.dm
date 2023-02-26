/mob/verb/NewbieForm()

	var/Form/Newbie/frm = new()

	frm.DisplayForm() //? Send usr the form.

/mob/var/race //human, ogre, or jellyfish



/Form/Newbie
	var/name

	var/gender

	var/gender_1 = "male"
	var/gender_2 = "female"
	var/gender_3 = "neuter"

	var/race
	var/race_values = list("human","ogre","jellyfish")


/Form/Newbie/Initialize()
	name   = usr.name
	gender = usr.gender
	race   = usr.race


/Form/Newbie/ProcessForm()

	usr.name = name

	usr.gender = gender

	usr.race = race

	usr << browse("You have been modified!")


/Form/Newbie/HtmlLayout()
	return {"

Your name: [name] <br>
Your gender:      <br>
[gender_1] male   <br>
[gender_2] female <br>
[gender_3] other  <br>
Your race: [race] <br>
[submit]

"}
