/buoy_module
	var/list/buoy_component/components

/buoy_module/New()
	..()
	if(islist(components))
		for(var/buoy_component/_component as anything in components)
			components[_component] = new/buoy_component(src)

/buoy_module/proc/Initialize(...)
