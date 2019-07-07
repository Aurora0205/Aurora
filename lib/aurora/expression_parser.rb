require "aurora/additional_methods.rb"

# for seed data
class ExpressionParser
  class << self
    FOREIGN_KEY_SYMBOL = "F|"
    def parse config_val, maked
      require AdditionalMethods.filepath if AdditionalMethods.filepath.present?
      case 
      when config_val.instance_of?(Array)
        return config_val
      when config_val.nil?
        return nil
      when is_foreign_key?(config_val)
        # remove 'F|'
        str_model = config_val.sub(FOREIGN_KEY_SYMBOL, "")
        model = eval(str_model)
        return model.pluck(:id)
      when is_expression?(config_val)
        # remove '<>'
        expression = config_val.strip[1..-2]
        return self.parse(eval(expression), maked)
      else 
        if config_val.instance_of?(String)
          # escape \\
          [config_val.tr("\\","")]
        else
          [config_val]
        end
      end
    end
  end
end

# for loop data
class LoopExpressionParser
  class << self
    FOREIGN_KEY_SYMBOL = "F|"
    def parse config_val, maked
      require AdditionalMethods.filepath if AdditionalMethods.filepath.present?
      case 
      when config_val.instance_of?(Array)
        return config_val.size
      when config_val.instance_of?(Integer)
        return config_val
      when config_val.nil?
        return 1
      when is_foreign_key?(config_val)
        # remove 'F|'
        str_model = config_val.sub(FOREIGN_KEY_SYMBOL, "")
        model = eval(str_model)
        return model.pluck(:id).size
      when is_expression?(config_val)
        # remove '<>'
        expression = config_val.strip[1..-2]
        return self.parse(eval(expression), maked)
      else 
        return 1
      end
    end
  end
end