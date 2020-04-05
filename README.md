# completion-treesitter
Treesitter source and more for [completion-nvim](https://github.com/haorenW1025/completion-nvim).

This is a basic completion source based on the treesitter api of neovim.

# Quickstart

Open a buffer of a supported filetype (only c for now) and enjoy !
Actually, you will see two things : if you go on any identifier, its usages and definition should highlight automatically.

An other thing is that the plugin provides two text objects :
  - `gn` an incrementally growing node (identifier, expression, line, ...)
  - `gf` current context/function.

# Goals
The aim of the plugin is mainly to fiddle a bit with treesitter, and a nice way is completion, but there is many things we can do with it.

There is still some goals for the plugin:
  - As hackable as possible
  - As fast as possible

# TODO
That's the ideas I had in mind at start, but feel free to suggest anything !

  - [ ] Completion
    - [x] Basic
    - [x] Suggest only symbol in current scope
    - [ ] Intelligent suggestions (based on types for examples)
    - [ ] Include file handling (`:h include-search`)
  - [x] Text objects
    - [x] Incremental selection `gn`
    - [x] Current context `gf`
  - [ ] Refactoring helpers
    - [x] Highlight identifiers at point
    - [ ] Find definition/declaration
    - [ ] "Intelligent" search/replace
    - [ ] Signature help
