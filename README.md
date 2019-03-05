# REBOL-to-HTML
A REBOL dialect for generating HTML inspired by cl-Markup for Common Lisp.

This is a very simple script that converts a `block!` into a `string!` of HTML.

There are two functions currently:
`markup` and `html5`

Both accept a `block!` and return a `string!`

Here is an example of how it works:

```
markup [html [div [h1 "Hello World!"]]]

returns

{
<html >
<div >
<h1 >
Hello World!
</h1>
</div>
</html> }
```

`html5` does the same however instead of a raw conversion it adds the Doctype and open/closing HTML tags:
```
html5 [div [h1 "Hello World!"]]

returns

{<!DOCTYPE html>
<HTML>
<div >
<h1 >
Hello World!
</h1>
</div>
</HTML>}
```

In addition any blocks that start with a `string!` will be inserted directly:

```
markup [div [h1 "Hello"] [";&nbsp"] [h1 "World!"]]

becomes
{
<div >
<h1 >
Hello
</h1> ;&nbsp
<h1 >
World!
</h1>
</div> }
```
The real power of markup comes from the `'do` keyword which allows you to insert REBOL code into the markup.
For instance, if you wanted to generate a dropdown menu containing the Display/Value pairs in a block! 
You could write something like this:
```
nums: [One 1 Two 2 Three 3]
markup [select id "test" do [foreach [disp val] nums [markup [option value val disp]]]]

this becomes:

{
<select id="test" >
<option value=1 >
One
</option>
<option value=2 >
Two
</option>
<option value=3 >
Three
</option>
</select> }
```
