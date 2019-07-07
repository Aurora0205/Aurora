class DataStructure
  class << self
    def gen data
      data.reduce(Hash.new) do |acc, r|
        str_model = r.first.to_s
        acc[str_model] = r.second
        # set col type info which was taked from db
        set_col_type(acc[str_model], get_col_type(str_model))

        acc
      end
    end

    private
    
    def get_col_type str_model
      model = eval(str_model)
      model.columns.reduce(Hash.new) do |acc, col|
        acc[col.name] = { type: col.type.to_s, sql_type: col.sql_type.to_s }

        acc
      end
    end

    def set_col_type config_data, col
      col.each do |key, val|

        config_data.each do |e|
          e[:col] ||= Hash.new
          # config_data has not its column data
          unless e[:col].has_key?(key.to_sym)
            # prepare setting to run default seed

            # set nil to seed data
            e[:col][key.to_sym] = nil

            # set type info
            e[:type] ||= Hash.new
            e[:type][key.to_sym] = val[:type]

            # set sql_type info
            e[:sql_type] ||= Hash.new
            e[:sql_type][key.to_sym] = val[:sql_type]
          end
        end

      end
    end

  end
end