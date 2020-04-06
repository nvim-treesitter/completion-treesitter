[![Gitter](https://badges.gitter.im/completion-nvim/community.svg)](https://gitter.im/completion-nvim/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
# completion-treesitter
Treesitter source and more for [completion-nvim](https://github.com/haorenW1025/completion-nvim).

This is a basic completion source based on the treesitter api of neovim.

# Quickstart

Open a buffer of a supported filetype (only c for now) and enjoy !
Actually, you will see two things : if you go on any identifier, its usages and definition should highlight automatically.

An other thing is that the plugin provides two text objects :
  - `gn` an incrementally growing node (identifier, expression, line, ...)
  - `gf` current context/function.

# Adding new filetypes

For now, you should look the `after/ftplugin/c.vim` file, and [tree-sitter documentation on
queries](https://tree-sitter.github.io/tree-sitter/syntax-highlighting#queries). Feel free to open an issue if you need
help, or open a PR if you don't.

If you find a bug in any filetype, or a weird behaviour, open an issue to describe how the behaviour differs from the
expected one.

Current supported filetypes:
| Filetype	| Parser |
|----		|----|
| C			| Neovim builtin |
| Python	| [tree-sitter-python](https://github.com/tree-sitter/tree-sitter-python) |
| Lua		| [tree-sitter-lua](https://github.com/Azganoth/tree-sitter-lua) |


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
    - [x] Find definition/declaration
    - [x] "Intelligent" rename (`completion_treesitter#smart_rename()`)
    - [ ] "Intelligent" search/replace
    - [ ] Signature help
