" Last Change: 2020 avr 09

" This query Extracts context definitions (like functions, of for example, Rust bracketed contexts)
let b:completion_context_query = ['function', 'if_statement', 'for_in_statement', 'repeat_statement', 'local_function']

" This is the name of an identifier node (as shown in treesitter playground), it will be used
let b:completion_ident_type_name = "identifier"

" This is the query that will be used to search for the definition of
" a given identifier, it is mandatory to have an @def in it to tag the identifier of the declaration.
" The other @-tag will be used to name the completion item during completion
let b:completion_def_query = [
			\ '(variable_declarator (identifier) @def @v)',
			\ '(variable_declarator (identifier) @assoc (property_identifier) @def @v)',
			\ '(function (function_name (identifier) @assoc (property_identifier) @def @f))',
			\ '(function (function_name (identifier) @def @f))',
			\ '(local_function (identifier) @def @f)',
			\ '(parameters (identifier) @def @v)',
			\ '(loop_expression (identifier) @def @v)',
			\ ]
