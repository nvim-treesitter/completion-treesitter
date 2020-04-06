" Last Change: 2020 avr 06
" These variables are the heart of vim treesitter, they allow the plugin to interact simply with the syntax tree.
" If you consider adding a new filetype consider using https://tree-sitter.github.io/tree-sitter/playground to test your 
" queries on a given source code.
"
" All of these variables are basically treesitter queries, made in a given purpose.


" This query Extracts context definitions (like functions, of for example, Rust bracketed contexts)
let b:completion_context_query = '((function_definition) @context)'

" This is the query which will be used to extract suggestions form your code.
" This suggestions will be filtered out to show only those in the current context, using b:competion_context_query
" The @-part of the query will later be used to tag the completion item, so feel free to add anything here
let b:completion_ident_query = '(function_declarator declarator: (identifier) @func)
            \ (preproc_def name: (identifier) @preproc)
            \ (preproc_function_def name: (identifier) @preproc)
            \ (parameter_declaration declarator: (identifier) @param)
            \ (parameter_declaration declarator: (pointer_declarator declarator: (identifier) @param))
            \ (array_declarator declarator: (identifier) @var)
            \ (pointer_declarator declarator: (identifier) @var)
            \ (init_declarator declarator: (identifier) @var)
            \ (declaration declarator: (identifier) @var)'

" This is the name of an identifier node (as shown in treesitter playground), it will be used
let b:completion_ident_type_name = "identifier"

" This is the query that will be used to search for the definition of
" a given identifier (will be added in the "%s" placeholder).
let b:completion_def_query = [
			\ '((preproc_def name: (identifier) @def) (eq? @def "%s"))',
			\ '((preproc_function_def name: (identifier) @def) (eq? @def "%s"))',
			\ '((pointer_declarator declarator: (identifier) @def) (eq? @def "%s"))',
			\ '((parameter_declaration declarator: (identifier) @def) (eq? @def "%s"))',
			\ '((init_declarator declarator: (identifier) @def) (eq? @def "%s"))',
			\ '((function_declarator declarator: (identifier) @def) (eq? @def "%s"))',
			\ '((array_declarator declarator: (identifier) @def) (eq? @def "%s"))'
			\ ]
