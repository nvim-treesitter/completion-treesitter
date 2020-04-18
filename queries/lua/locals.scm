;;; DECLARATIONS AND SCOPES

;; Variable and field declarations
((variable_declarator
   (identifier) @local.definition)
  (set! kind "v"))

((variable_declarator
   (field_expression object:(*) @local.definition.associated (property_identifier) @local.definition))
  (set! kind "v"))

;; Parameters
((local_function
   (parameters (identifier) @local.definition))
  (set! kind "v"))
((function
   (parameters (identifier) @local.definition))
  (set! kind "v"))

;; Function definitions
;; Functions definitions creates both a definition and a new scope
((function
   (function_name_field
     object: (identifier) @local.definition.associated
     (property_identifier) @local.definition)) @local.scope
  (set! kind "m"))

((function
   (function_name (identifier) @local.definition)) @local.scope
  (set! kind "f"))

((local_function
   (identifier) @local.definition) @local.scope
  (set! kind "f"))

((if_statement) @local.scope)
((for_in_statement) @local.scope)
((repeat_statement) @local.scope)
;; Loops
((loop_expression
   (identifier) @local.definition)
  (set! kind "v"))

;;; REFERENCES
((identifier) @local.reference)
