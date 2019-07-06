FOREIGN_KEY = /^F\|[A-Z][A-Za-z0-9]*$/
def is_foreign_key? val;
  return false unless val.kind_of?(String)
  FOREIGN_KEY =~ val 
end

EXPRESSION = /^\s*<.*>\s*$/
def is_expression? val
  return false unless val.kind_of?(String)
  EXPRESSION =~ val 
end

ENUM = /^enum(\s*.)*$/
def is_enum? val
  return false unless val.kind_of?(String)
  ENUM =~ val 
end