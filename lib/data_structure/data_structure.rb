require "seeder/seeder.rb"

class DataStructure
  class << self
    def gen data
      data.reduce(Hash.new) do |acc, r|
        str_model = r.first.to_s
        acc[str_model] = r.second
        # set col data which was taked from db
        set_col(acc[str_model], get_col(str_model))
        # set expand '< >'
        set_expand_expression(acc[str_model])
        # set seed data 
        set_seed(acc[str_model])

        acc
      end
    end

    private
    def get_col str_model
      model = eval(str_model)
      model.columns.reduce(Hash.new) do |acc, col| 
        acc[col.name] = { type: col.type.to_s }
        acc
      end
    end

    def set_col config_data, col
      col.each do |key, val|
        config_data.each do |e|
          e[:col] ||= Hash.new
          # config_data has not its column data
          unless e[:col].has_key?(key.to_sym)
            # set nil
            e[:col][key.to_sym] = nil
            # set type info
            e[:type] ||= Hash.new
            e[:type][key.to_sym] = val[:type]
          end
        end
      end
    end

    def set_expand_expression config_data
      # Unimplemented
    end

    def set_seed config_data
      # id does't gen seed data 
      block = ->(str){ [:id].include?(str) }
      config_data.each do |e|
        next if e[:type].nil?
        e[:type].each do |key, val| 

          if block.call(key)
            e[:col][key.to_sym] = nil
          else
            e[:col][key.to_sym] = Seeder.gen(e[:loop], e[:type][key.to_sym]) 
          end

        end
      end
    end
  end
end