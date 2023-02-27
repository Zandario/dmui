# DM HTML Library

===================

You can use HTML forms to obtain information from users in a graphical dialogue. To retrieve a single piece of information, one normally uses input(), but a long chain of prompts can become irksome to the user. The solution is to create a form containing entries for each item.

Programs that generate HTML (or any other code for that matter) often appear rather noisy. This programming library, if it achieves anything, helps to elliminate much of that noise, so your code doesn't look like a garbled superposition of two languages arguing with each other over who controls the punctuation.

## Contents

- [Tutorial](#tutorial)
  - [Defining a Form](#defining-a-form)
  - [Displaying a Form](#displaying-a-form)
  - [Processing a Form](#processing-a-form)
  - [Initializing a Form](#initializing-a-form)
  - [Basic Interface Elements](#basic-interface-elements)
  - [Form Layout](#form-layout)

- [Reference](#reference)
  - [User Defined Interface Variables](#user-defined-interface-variables)
  - [Interface Types](#interface-types)
  - [Display Size](#display-size)
  - [Maximum Length](#maximum-length)
  - [Possible Values](#possible-values)
  - [Form Label](#form-label)
  - [Hidden Variable](#hidden-variable)
  - [Wrapping](#wrapping)
  - [Extra Input Parameters](#extra-input-parameters)
  - [Pre-Defined Interface Variables](#pre-defined-interface-variables)
  - [`submit`](#submit)
  - [`reset`](#reset)
  - [Non-Interface Variables](#non-interface-variables)
  - [Reusable Forms](#reusable-forms)
  - [Form Title](#form-title)
  - [Form Submission Method](#form-submission-method)
  - [Default Input Field Maximum Length](#default-input-field-maximum-length)
  - [Default Input Field Size](#default-input-field-size)
  - [Sub Path](#sub-path)
  - [Extra Form Parameters](#extra-form-parameters)
  - [`DisplayForm()`](#displayform)
  - [`HtmlLayout()`](#htmllayout)
  - [`Initialize()`](#initialize)
  - [`ProcessForm()`](#processform)
  - [`GetSelfUrl()`](#getselfurl)


## Tutorial

You define a form by deriving your own from the base `/datum/dmui_form` type. The variables you define become entry fields in the form. These are called interface elements.

### Defining a Form

Here is a very simple form definition.

# include "html/form.dm" Form/Newbie var name gender race

That defines a form type `/datum/dmui_form/Newbie` with three fields: name, gender, and race.

### Displaying a Form

You can submit this form to a player by calling `DisplayForm()`.

```dm
/mob/verb/myinfo()
	var/datum/dmui_form/Newbie/new_form = new()
	new_form.DisplayForm() //? Send our user the form.
```

If you try that, you should see the form pop up in the browser window when you use the `myinfo` verb.

There are several things to note at this point. One is that the form doesn't do anything. Another is that all three fields use the same type of interface element--a text box. Lastly, the form always starts out blank. The following examples will rectify these problems.

### Processing a Form

When the form is complete, its `ProcessForm()` procedure is called. You can define it to do whatever you want.

```dm
// Newbie.dm

/mob/var/race //human, ogre, or jellyfish

/datum/dmui_form/Newbie/ProcessForm()
	usr.name   = name
	usr.gender = gender
	usr.race   = race
	usr << browse(" You have been modified!")
```

It is a good idea to output something to the browser acknowledging receipt of the form. Otherwise, the user is left feeling like nothing happened.

### Initializing a Form

In the same way that the form variables were accessed in `ProcessForm()`, they can be initialized in `Initialize()`. This is automaitcally called by `DisplayForm` before generating the form's HTML.

```dm
// Newbie.dm

/datum/dmui_form/Newbie/Initialize()
	name   = usr.name
	gender = usr.gender
	race   = usr.race
```

Of course, you are free to initialize the form variables in the same place where you create the form. Do whichever is more convenient.

### Basic Interface Elements

A text-box is a good interface element for entering the name, but it is not so good for race and gender, where the possible values are restricted. By telling the form to restrict the range of values the user may enter, it will automatically use a more appropriate interface element.

```dm
// Newbie.dm

/datum/dmui_form/Newbie
	var/name
	var/gender
	var/gender_1 = "male"
	var/gender_2 = "female"
	var/gender_3 = "neuter"
	var/race
	var/race_values = list("human","ogre","jellyfish")
```

Notice the two different techniques for limiting the input values. In the case of gender, we enumerated three possibilities by declaring variables `gender_1`, `gender_2`, and `gender_3`. That produces a _radio toggle_ interface element. The user can turn on any one and only one of the three genders.

The second technique for restricting the range of input is with a list of values. By defining `race_values`, we told the form to use a _selection list_ interface element. The user can select one item from the list.

There are other types of interface elements. You can learn about those in the reference section. These basic ones will satisfy most of your needs.

### Form Layout

The layout of your form has so far been automatically generated. You can design the html yourself by overriding the `HtmlLayout()` procedure.

```dm
// Newbie.dm

/datum/dmui_form/Newbie/HtmlLayout()
	return {"
Your name: [name] <br>
Your gender:      <br>
[gender_1] male   <br>
[gender_2] female <br>
[gender_3] other  <br>
Your race: [race] <br>
[submit]
"}
```

Wherever you want an interface element to appear, you simply embed the associated variable. (Before `HtmlLayout()` is called, each of the variables is automatically assigned to the html code that produces the desired interface element.) The special submit variable produces a button that submits the form. There is also a reset variable so the user can undo changes and start over.

Since this is an HTML document, you have to use wherever you want a line break. For convenience, we did use a text document (curly braces around the double quotes), so newlines could be embedded directly in the text, but the browser treates those just like spaces. You can use any other HTML tricks you want in order to control the appearance.

## Reference

A form has three basic components: interface variables, graphical layout, and a processing procedure. The details of these are described in the following reference sections.

### User Defined Interface Variables

A form is defined by the variables it contains. Each interface variable represents a piece of information that the user can view and modify. There are also non-interface variables that control the properties of the interface elements or that you define for your own purposes.

The control variables are described in the following sections.

#### Interface Types

By default, each variable you define creates a corresponding text box interface ellement. You can select a different interface element by defining an `_interface` control variable.

```dm
/datum/dmui_form/Login
	var/name
	var/password
	var/password\_interface = PASSWORD
```

As the above example demonstrates, the control variable is defined with the same base name as the interface variable with `_interface` appended.

In this particular example, the PASSWORD interface type was used. That prevents the user's input from being displayed on the screen. This and the other interface types are described below.

##### TEXT

This is the default interface element. It presents a text box in which the user may edit a short text string. Note that this may be used for editing numbers as well as text. If the input type of the variable is numeric (achieved by initializing the variable to a number), the input from the text box will be automatically converted to a number for you.

##### PASSWORD

This is just like TEXT, but the contents are not visible on the screen.

##### TEXTAREA

Like a text box, this allows the user to input any value. It may be used for editing multi-line messages. This is the default interface element if you set the `_size` control variable to a value of the form "10x30" where 10 is the number of rows and 30 is the number of columns to display at one time.

##### SELECT

A selection list restricts the user to a choice of one value from a list. This is the default interface element if you set the `_values` control variable.

##### MULTI_SELECT

This is just like SELECT, except the user may select more than one item from the list.

##### CHECKBOX

The user may turn this interface element on or off. When it is off, the variable has a false value (like null) and when it is on, it has a true value (like 1).

##### CHECKLIST

This produces a list of check boxes, each with a different corresponding value. The functionality is similar to MULTI_SELECT, but you have control over how each item in the list is displayed. This interface behaves a little differently from the others during HtmlLayout(). The value of the variable is a list of the values you assigned to the `_values` control variable and each of these has an associated html value. You access the html by indexing the interface variable with each of the possible values. When the form is processed, the interface variable will contain a list of the values checked by the user.

##### RADIO

A radio toggle lets the user pick one of a number of options. You don't use this directly but instead define numbered control variables for each option (`_1`, `_2`, `_3`, and so on). You may assign values to each of these. If you do not, the option number will be used.

##### RADIO_LIST

This is like a CHECKLIST except the user may only choose one item from the list. The choices are assigned to `_values` and the user's response is assigned to the interface variable. You access the html by indexing the interface variable with each of the possible values, just as with CHECKLIST.

##### HIDDEN

This allows you to hide an interface variable from the user. You might want to do that when the form is one of a sequence of dialogues and you need to retain information from previous steps as you move along. Like any other interface type, you have to embed the variable in the html if you override HtmlLayout(). To have the variable automatically embedded, use the `form_hidden` control variable instead.

##### BUTTON

This generates a button on the form. When the user clicks it, your procedure (called varnameClick()) is called. The value of this variable (when DisplayForm() is called) is displayed on the button face. If the value is null, the name of the variable is used instead.

##### PROMPT

Like BUTTON, this produces a button on the form. Your varnameClick() procedure is called and the return value is assigned to this variable. That allows you to prompt the user for anything you want. The most common prompts have special interface elements that do it for you.

##### PROMPT_FOR_ICON

This is like PROMPT, except you don't define a Click() proc. It does the prompting for you. The icon file uploaded by the user gets assigned to the interface variable.

##### PROMPT_FOR_SOUND

This prompts the user for a sound file to upload.

##### PROMPT_FOR_FILE

This prompts the user for any file to upload. This works in CGI mode (through a web browser) as well as in Dream Seeker. The generic PROMPT and BUTTON interfaces do not work in CGI mode, so if you want the user to upload a file, do it through this specific interface.

##### SUB_FORM

This is a variable containing another form object. It is the default interface type if you initialize the variable to a new instance of a form (which you have to do anyway for it to work). The sub-form is embedded in the main form and is submitted and processed as part of a single HTML form.

#### Display Size

The `_size` control variable specifies the amount of data to display at one time (without scrolling) in the interface element. It does not effect the maximum length of data that the user may enter.

With a text box interface element, this specifies the number of characters that may be visible at one time. The default behavior depends on the browser. You can set your own default using `form_default_size`.

For a TEXTAREA interface element, the size specifies the number of rows to display. In addition, the number of columns may be set using the format "30x10" where 30 is the number of columns and 10 is the number of rows. In that case, the interface element defaults to TEXTAREA.

#### Maximum Length

The `_maxlen` control variable specifies the maximum number of characters that the user may enter. If none is specified, `form_default_maxlen` will be used. If that is not specified, no limit will be applied.

#### Possible Values

The `_values` control variable specifies a list of values to display in a selection list. If it is defined, the interface element defaults to SELECT.

#### Validate Input

The `_validate` control variable determines whether it is an error to receive input from the user that is not in the values list. It is on by default.

#### Form Label

The `_label` control variable is used by the default form layout generator to label the interface element. If no label is specified, the variable name (capitalized) is used.

#### Hidden Variable

The `_hidden` control variable causes the variable to be automatically stored in the form but with no visible interface. (Assign _hidden to a true value.) This is a similar effect to the [HIDDEN](#hidden) interface type, except HIDDEN variables are not automatically embedded in the form if you override HtmlLayout().

#### Wrapping

The `_wrap` control variable may be used to configure the text wrapping in a textarea edit box. It may be assigned to any of the following:

##### NO_WRAP

no wrapping of text

##### SOFT_WRAP

text is wrapped but newlines are not inserted into the result

##### HARD_WRAP

text is wrapped and newlines are inserted where it wraps

#### Extra Input Parameters

If you need to insert some special html code into the input tag for an interface element, you may do so with the `_extra` control variable. A common example of this would be the insertion of [Java Script](http://www.javascript.com) code.

##### Example

```dm
/datum/dmui_form/MyForm
	var/submit_extra = {"OnClick='return confirm("Are you sure?");'"}
```

See also, [form_extra](var/other/form_extra).

### Pre-Defined Interface Variables

In addition to the interface elements defined above, there are two more: the submit and reset buttons. These are pre-defined for you.

#### `submit`

The submit interface variable is used to place the submit button on the form. You can assign a different value to this variable to change the text displayed on the button face. The default is "Submit". The special control variable `form_url` may be set to the URL that you want to receive the submitted form. This defaults to the form object used to display the form.

#### `reset`

The reset interface variable is used to place a reset button on the form. When the user pushes the reset button, the displayed form is restored to its initial state so the user can start over. You can assign a different value to this variable to change the text displayed on the button face. The default is "Reset". If you set it to null, the form will not contain a reset button.

### Non-Interface Variables

In addition to interface variables and their associated control variables, you may have reason to define other variables that are used for your own purposes. These should be marked as such by defining them to be `global`, `const`, or `tmp`. Such variables will be ignored when constructing the form interface.

#### Reusable Forms

One such pre-defined variable is the `form_reusable` variable. It defaults to a false value, indicating that you only intend the user to submit the form once after each call to `DisplayForm()`.

If you want the user to be able to repeatedly submit the form, you should set this parameter to a true value (like 1).

#### Form Title

Another form control variable is `form_title`. It is empty by default, but you can set it to whatever title you wish the form to have.

#### Form Submission Method

The `form_method` variable controls the method used by the web browser to submit the form results. In BYOND mode (ie in Dream Seeker), this must be "get".

#### Default Input Field Maximum Length

The `form_default_maxlen` variable sets the default maximum length for input fields when none is supplied. If you do not specify a maximum input length, no limit will be placed on the length of data the user may submit. The numerical value is the number of characters that will be allowed.

#### Default Input Field Size

The `form_default_size` variable sets the default input field display size. If you do not specify a field size, the browser will choose one for you. The numerical value is the number of characters that will be displayed.

#### Sub Path

The `form_sub_path` variable contains extra path information in the form's URL, which is tagged on after the `.dmb` name. Be careful if you use this, because the extra path information is included in the default base href when you output an html page in CGI mode.

#### Extra Form Parameters

The contents of the `form_extra` variable are inserted into the form tag in the html output. You could use this to insert extra code, such as Java Script that is not supported directly by the other form variables.

##### Example

```dm
/datum/dmui_form/MyForm
	form_extra = {"OnSubmit='return confirm("Are you sure?");'"}
```

See also, [_extra](var/udef_extra) control variable.

### `DisplayForm()`

The form's `DisplayForm()` procedure is used to send the form to a player. By default, it is sent to `usr`, but you can pass in any mob reference you like.

You should create a new instance of the form for each call to `DisplayForm()`, unless you always wait until the form has been completely processed before displaying it again.

### `Initialize()`

The form's `Initialize()` procedure is called by `DisplayForm()` before generating the HTML. This is to allow you to initialize form variables. You do not have to do initialization of form variables here; it is simply defined for your convenience.

### `HtmlLayout()`

You define the `HtmlLayout()` procedure to return the HTML text describing the form. The default procedure simply displays the name of each interface variable followed by the interface element. (You can also use the [_label](#form-label) control variable to specify an alternate prompt to display.)

Perhaps the slickest part of the Form programming interface is how you embed each interface element in your form layout text. Before `HtmlLayout()` is called, each interface variable is automatically assigned to the corresponding HTML element. All you have to do is insert the variable into the layout text. That elliminates most of the noisy HTML so you can see what you are doing.

If you are familiar with HTML, you may have noticed that the form layout does not include the actual `<our_form>` element. That is automatically generated for you before the form is submitted to the user.

### `ProcessForm()`

This procedure is called when the user submits the form. Basic checks are performed first to make sure the form was indeed displayed to the user who is submitting it and that the input conforms to the specified limits. After that, `ProcessForm()` is called and you can act upon the user's input.

If the form is reusable, there may be multiple calls to `ProcessForm()` for each call to `DisplayForm()`. Otherwise, there will only be one.

### `GetSelfUrl()`

This procedure returns a URL text string containing all of the form variables. It may be used, for example, to generate a hyperlink that causes the form to be processed. Currently, prompt variables are not included in the URL.
