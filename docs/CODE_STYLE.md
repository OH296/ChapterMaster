# How to style your code

## Required:
- Constructor names should always use PascalCase.\
That is to prevent any possible overlap with variable names, that is known to cause errors with YYC compiler.
- As such, variable names, function names, etc, should never use PascalCase.\
The exception are enum entries.

## Recommended:

### File names:
Here it's simple, just follow the general GameMaker way of naming files with type prefixes.

### Names:
All variable names, function names, etc. should use snake_case.\
Unless stated otherwise, all names should just be `variable_name`, with no additional prefixes.
- **Local** variables are recommended to have a `_` prefix. This may ease code reading.
  - Example: `var _example_e1`.
- **Global** variables don't require any additional rules, as they already require a `global.` prefix to use.
  - Example: `global.example_e1`.
- **Functions** don't require any prefixes, but to avoid accidental overlaps with instance variables:
  - Name them with at least 2 words: `draw_something()` and not `drawing()`.
  - And as an action: `draw_something()` and not `green_apple()`.
  - Here we just try to follow default GM function naming scheme.
- **Macro** constants:
  - A short `PREFIX_` should state their group in all caps.
  - After the prefix, they should be written in snake_case.
  - Examples: `COL_bright_red`, `COL_dark_green`; `DIR_left`, `DIR_up`.
  - Here we just try to follow default GM macro naming scheme.
- **Enum** constants:
  - Name of the enum should start with an `e` prefix and be written in all caps.
  - Name of the enum entries should use PascalCase.
  - Example: `enum eCOLORS` with entries `DarkRed`, `Blue`, etc. 

### General Styling:
- It's recommended to initialize variables when declaring them. I.e `var variable = 0`, instead of just `var variable`.
- It's also recommended to declaring each variable on a new line, avoiding `var variable1 = 0, variable2 = 2...`, to improve readability.
- `&&` and `||` should be used instead of `and` and `or`.\
This is to ensure compatibility with JavaScript formatters.
- Indentation should be 4 **spaces**. Don't use tabs. Different editors interpret tabs differently.
- Remember to use semicolons at the end of simple statements.
- You can use [this](https://beautifier.io/) JavaScript formatter to format your code. The format it outputs fits our requirements. Just be sure to select:
  - Indent with 4 spaces.
  - Allow unlimited newlines between tokens.
  - Don't wrap lines.
  - Spaces before conditional.
- **If you use JS formatters they break `$"something {variable}"` syntax, by adding a space after `$`, i.e. `$ "something {variable}"`. Be sure to manually fix this after using a formatter.**