let b:completion_context_query = ['arrow_function', 'if_statement', 'method_definition', 'function_declaration', 'statement_block', 'for_in_statement']

let b:completion_ident_type_name = "identifier"

let b:completion_def_query = [
      \'(for_in_statement (identifier) @def @v)',
      \'(function_declaration name: (identifier) @def @f)',
      \'(function_declaration parameters: (formal_parameters (required_parameter (identifier) @def @v)))',
      \'(function_declaration parameters: (formal_parameters (optional_parameter (identifier) @def @v)))',
      \'(arrow_function parameters: (formal_parameters (required_parameter (identifier) @def @v)))',
      \'(arrow_function parameters: (formal_parameters (optional_parameter (identifier) @def @v)))',
      \'(method_definition parameters: (formal_parameters (required_parameter (identifier) @def @v)))',
      \'(method_definition parameters: (formal_parameters (optional_parameter (identifier) @def @v)))',
      \'(variable_declarator (identifier) @def @v)'
      \]
