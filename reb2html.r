Rebol [
	Title: "Rebol 2 HTML"
	Purpose: {
	Converts Rebol to HTML markup similar to cl-markup
	for common lisp. Largly as as exercise in learning parse
	while still making something useful.
	}
	Version: 1.0
	File: %reb2html.r	
]

push: function [
	item "what to push"
	loc "where to push it"
][][insert item loc]

pop: function [
	loc "What to pop"
][temp][
	temp: loc/1
	remove loc
	return temp
]
reset: does [
	ret-str: copy ""
	close-tags: copy []
]

if value? 'singletons [unprotect 'singletons]
singletons: [br area base col embed hr img input link meta param source track wbr]
protect 'singletons

; global string to allow recursive building of code
ret-str: copy ""
; global list to hold closing tags
close-tags: copy []

if value? 'rule2 [unprotect 'rule2]
rule2: [
	; the first item in a block is a word for the tag or  a string
	[set item word! | set item string!] (
		; if the word! is a string then push a newline on the closing tags and skip through
		either string! = type? item [
			push close-tags "^/"
			append ret-str item
		][
			;otherwise push the start of the tag and the tag name
			append ret-str rejoin ["^/<" item " "]
			; if it's a singleton push /> on close tags, otherwise push normal closing tag
			either find singletons item [
				push close-tags "/>"
			][
				push close-tags rejoin ["^/</" item "> "]
			]])
	; the next word(s) if "any" is either an attribute followed by a string or an attribute followed by a variable
	any [set atr word! set atr-str string! (append ret-str rejoin [atr "=" mold atr-str " "]) |
		set atr word! set val word! (append ret-str rejoin [atr "=" mold (get val) " "])]
	; if this is not a singleton (or 'raw) stick the closing > after all the attrs
	(if (not find singletons item) and (string! <> type? item) [append ret-str ">^/"])
	; this recursively parses any blocks using this same rule
	any [into rule2]
	; This allows you to insert rebol code inside the markup block by using the 'do' keyword
	; followed by a code block
	any ['do set blk block! (do blk)]
	; Any values entered in the HTML such as the wording between h1 tags will be picked up here.
	; along with any string entered after 'raw i.e. ";&nbsp" etc
	any [ set addtl string! (append ret-str addtl) ]
	any [ set addw word! (append ret-str rejoin [mold (get addw) " "])]
	; this finally adds the closing tag once everything else is finished.
	(append ret-str pop close-tags)
]
protect 'rule2

markup: function [
	code [block!] "Code to convert"
][markup-str][

	markup-str: copy ""
	parse code rule2
	; if we are done recursing and no more tags to close
	if empty? close-tags [
		markup-str: copy ret-str
		;reset global string
		ret-str: copy ""
		;return copy
		return markup-str
	]
]

html5: function [
	code [block!] "Code to markup"
][html5-str][
	html5-str: copy ""
	append ret-str "<!DOCTYPE html>^/<HTML>"
	push close-tags "^/</HTML>"
	parse code rule2
	if 1 = length? close-tags [; i.e only closing HTML tag left
		html5-str: copy ret-str
		append html5-str reduce [pop close-tags]
		ret-str: copy ""
		return html5-str
	]
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Usage Examples ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;baseline test data
data: [div id "hello" style "display:none"
	[h1 "This is a test!"]
	[br]
	[p id "help"]]

;more rigorous test data
more-data: [body
	[div style "Text-align:center"
		[h2 "Hello World!"]
		[button type "button" onclick "document.getElementById('test-div').style.display='inline'"  "Open"]
		["&nbsp;&nbsp;&nbsp;&nbsp;"]
		[button type "button" onclick {document.getElementById("test-div").style.display="none"} "Close"]]
	[div id "test-div" style "display:none"
		[h1 "Hello world! Again!"]
		[br]
		do [ddn/onchange "numbers" [1 one 2 two 3 three] "lrt(this.value)"]
	]
	[input type "text" value "Enter Text!"]
	[script
		["function lrt (val) {alert(val)}"]]
]

ddn: func [
	{Example of creating a func to return a prebuilt piece of code.
	 In this case a drop down box.}
	
	ddn-id [string!] "ddn id"
	opts [block!] "options list"
	/onchange "add an onchange event"
	fun [string!] "script to run onchange"
][
	;; originally on one line but expanded for illustrative purpose
	either onchange [
		return reduce [ markup [ select id ddn-id onchange fun do [
					foreach [txt val] opts [
						markup [option value val txt]
					]
				]
			]
		]
	][
		return reduce [ markup [ select id ddn-id do [
					foreach [txt val] opts [
						markup [option value val txt]
					]
				]
			]
		]
	]
]