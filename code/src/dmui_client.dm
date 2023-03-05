
/// Delete forms waiting on players who log out.
/client/Del()

	var/buoy_interface/F

	for(F)
		if(F.user == mob)
			del F

	return ..()
