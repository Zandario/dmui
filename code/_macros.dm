#define get_turf(A) (get_step(A, 0))

#define get_x(A) (get_step(A, 0)?.x || 0)
#define get_y(A) (get_step(A, 0)?.y || 0)
#define get_z(A) (get_step(A, 0)?.z || 0)


#define SEND_OUTPUT(_TARGET, _CONTENT)  _TARGET << output(_CONTENT)

#define TO_WORLD(_CONTENT) world << _CONTENT


#define SEND_BROWSER(_TARGET, _CONTENT, _NAME) _TARGET << browse(_CONTENT, _NAME)
#define STOP_BROWSER(_TARGET, _NAME)           _TARGET << browse(null,     _NAME)


#define JOINTEXT(X) jointext(X, null)
