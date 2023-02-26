
/// Delete forms waiting on players who log out.
/client/Del()

	var/Form/F

	for(F)
		if(F.form_usr == mob)
			del F

	return ..()
