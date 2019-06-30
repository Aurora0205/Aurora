class ExpressionParser
  class << self
    FOREIGN_KEY_SYMBOL = "F:"
    def parse config_val
      case 
      when config_val.instance_of?(Array)
        return config_val
      when config_val.nil?
        return nil
      when is_foreign_key?(config_val)
        # remove 'F:'
        str_model = config_val.sub(FOREIGN_KEY_SYMBOL,"")
        model = eval(str_model)
        return model.pluck(:id)
      when is_expression?(config_val)
        # remove '<>'
        expression = config_val.strip[1..-2]
        return self.parse(eval(expression))
      else 
        return [config_val]
      end
    end
  end
end