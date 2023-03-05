/**
 * The base type for nearly all physical objects in BYOND.
 */
/atom

/**
 * Called when an atom is created in BYOND (built in engine proc)
 *
 * Not a lot happens here, as we offload most of the work to the [Intialization][/atom/proc/Initialize] proc.
 */
/atom/New(loc, ...)
	. = ..()
	Initialize(src, args)


/**
 * The primary method that objects are setup.
 *
 * we don't use New as we have better control over when this is called and we can choose
 * to delay calls or hook other logic in and so forth.
 *
 * mapload: This parameter is true if the atom being loaded is either being intialized during
 * the Atom subsystem intialization, or if the atom is being loaded from the map template.
 * If the item is being created at runtime any time after the Atom subsystem is intialized then
 * it's false.
 *
 * ? NOTE: mapload isn't actually used in this codebase, but it's kept in mind since this was developed for SS13 in mind.
 * The mapload argument occupies the same position as loc when Initialize() is called by New().
 * loc will no longer be needed after it passed New(), and thus it is being overwritten
 * with mapload at the end of atom/New() before this proc (atom/Initialize()) is called.
 *
 * You must always call the parent of this proc, otherwise failures will occur as the item
 * will not be seen as initalized (this can lead to all sorts of strange behaviour, like
 * the item being completely unclickable)
 *
 * Any parameters from new are passed through (excluding loc), naturally if you're loading from a map
 * there are no other arguments
 *
 * Must return an [initialization hint][INITIALIZE_HINT_NORMAL] or a runtime will occur.
 *
 * !Note: the following functions don't call the base for optimization and must copypasta handling:
 * * A lot.
 */
/atom/proc/Initialize(mapload, ...)
	SHOULD_NOT_SLEEP(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if (is_datum_abstract())
		TO_WORLD("Abstract atom [type] created!")
		return Del(src)
