let b:completion_context_query = ['class_body', 'constructor_declaration', 'lambda_expression', 'method_declaration']

let b:completion_ident_type_name = "identifier"

let b:completion_def_query = [
      \'(class_body (field_declaration type: (type_identifier) @type declarator: (variable_declarator name: (identifier) @def @v)))',
      \'(constructor_declaration (formal_parameters (formal_parameter name: (identifier) @def @v)))',
      \'(lambda_expression (identifier) @def @v)',
      \'(method_declaration (formal_parameters (formal_parameter name: (identifier) @def @v)))',
      \'(variable_declarator name: (identifier) @def @v)'
      \]
