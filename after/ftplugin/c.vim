" Last Change: 2020 avr 06
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
" The other @-tag will be used to name the completion item during completion
let b:completion_def_query = [
			\ '((function_declarator declarator: (identifier) @def @func) %s)',
			\ '((preproc_def name: (identifier) @def @preproc) %s)',
			\ '((preproc_function_def name: (identifier) @def @preproc) %s)',
			\ '((pointer_declarator declarator: (identifier) @def @var) %s)',
			\ '((parameter_declaration declarator: (identifier) @def @param) %s)',
			\ '((init_declarator declarator: (identifier) @def @param) %s)',
			\ '((array_declarator declarator: (identifier) @def @var) %s)',
            \ '((declaration declarator: (identifier) @def @var) %s)'
			\ ]
