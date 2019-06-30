FOREIGN_KEY = /^:[A-Z][A-Za-z0-9]*$/
def is_foreign_key? val
  FOREIGN_KEY =~ val
end