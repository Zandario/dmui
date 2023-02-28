//# Constants


//## Input types
#define TEXT_ITYPE  1
#define NUM_ITYPE   2
#define ICON_ITYPE  3
#define SOUND_ITYPE 4
#define FILE_ITYPE  5


//## Interface elements
#define TEXT             1
#define PASSWORD         2
#define SELECT           3
#define MULTI_SELECT     4
#define CHECKBOX         5
#define RADIO            6  //! Variable that holds value of selected RADIO_OPTION.
#define RADIO_OPTION     7  //! Enumerated control variables _1, _2, _3, etc.
#define TEXTAREA         8  //! Input size is "[cols]x[rows]" or just rows.
#define HIDDEN           9
#define SUBMIT           10
#define RESET            11
#define BUTTON           12
#define PROMPT           13
#define PROMPT_FOR_ICON  14 //! Converts to PROMPT interface with ICON_ITYPE.
#define PROMPT_FOR_SOUND 15 //! Converts to PROMPT interface with SOUND_ITYPE.
#define PROMPT_FOR_FILE  16 //! Converts to PROMPT interface with FILE_ITYPE.
#define SUB_FORM         17 //! Form object or list of them.
#define CHECKLIST        18 //! List of checkboxes (produces a list of items and their associated html at display time).
#define RADIO_LIST       19
#define HIDDEN_LIST      20

#define SUBMIT_CLICK 1
#define BUTTON_CLICK 2

#define NO_WRAP   "off"
#define HARD_WRAP "hard"
#define SOFT_WRAP "soft"
