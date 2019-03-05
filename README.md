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
