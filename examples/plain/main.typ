// The example thesis in the plain theme.
//   typst compile --root . --font-path tmp/fonts examples/plain/main.typ
#import "/src/lib.typ": plain-theme
#import "../thesis.typ": example-thesis

#example-thesis(plain-theme)
