class ExpressionParser
  class << self
    def parse config_val
      case 
      when config_val.instance_of?(Array)
        return config_val
      when config_val.nil?
        return nil
      else 
        return [config_val]
      end
    end
  end
end