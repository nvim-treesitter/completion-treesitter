" Last Change: 2020 avr 07
" These variables are the heart of vim treesitter, they allow the plugin to interact simply with the syntax tree.
" If you consider adding a new filetype consider using https://tree-sitter.github.io/tree-sitter/playground to test your 
" queries on a given source code.
"
" All of these variables are basically treesitter queries, made in a given purpose.


" This query Extracts context definitions (like functions, of for example, Rust bracketed contexts)
let b:completion_context_query = '((function_definition) @context)'

" This is the name of an identifier node (as shown in treesitter playground), it will be used
let b:completion_ident_type_name = "identifier"

" This is the query that will be used to search for the definition of
" a given identifier, it is mandatory to have an @def in it to tag the identifier of the declaration.
" It is also possible to add a @type in an item, it will later be used to determine the type of the item.
" The other @-tag will be used to name the completion item during completion, it be like the "kind" part of complete_items
let b:completion_def_query = [
			\ '(function_declarator declarator: (identifier) @def @f)',
			\ '(preproc_def name: (identifier) @def @d)',
			\ '(preproc_function_def name: (identifier) @def @d)',
			\ '(pointer_declarator declarator: (identifier) @def @v)',
			\ '(parameter_declaration declarator: (identifier) @def @v)',
			\ '(init_declarator declarator: (identifier) @def @v)',
			\ '(array_declarator declarator: (identifier) @def @v)',
			\ '(declaration declarator: (identifier) @def @v)',
			\ '(enum_specifier name: (*) @type (enumerator_list (enumerator name: (identifier) @def @v)))',
			\ '(field_declaration declarator:(field_identifier) @def @m)',
			\ '(type_definition declarator: (type_identifier) @def @t)'
			\ ]
