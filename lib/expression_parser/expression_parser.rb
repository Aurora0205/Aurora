require "regex.rb"

class ExpressionParser
  class << self
    def parse config_val
      case 
      when config_val.instance_of?(Array)
        return config_val
      when config_val.nil?
        return nil
      when is_foreign_key?(config_val)

        puts "IN"
        str_model = config_val.sub(":","")
        model = eval(str_model)
        return model.pluck(:id)
      else 
        return [config_val]
      end
    end
  end
end