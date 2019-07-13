class DataStructure
  class << self
    def gen data
      data.reduce([]) do |acc, r|
        # r.second is block_data, like { Pref: {loop: 3}, Member: {loop: 3}... }
        block_data = r.second
        gen_structure(acc, block_data)
      end
    end

    private

    def gen_structure acc, block_data
      block_data.reduce(acc) do |acc, r|
        # r[0] is symbolize model
        # convert symbol to string
        r[0] = r[0].to_s
        # r.second is config_data, like {loop: 3, ...}
        config_data = r.second
        set_col_type(config_data, get_col_type(r[0]))

        acc.push(r)
      end
    end
    
    def get_col_type str_model
      model = eval(str_model)
      model.columns.reduce(Hash.new) do |acc, col|
        acc[col.name] = { type: col.type.to_s, sql_type: col.sql_type.to_s }

        acc
      end
    end

    def set_col_type config_data, col
      col.each do |key, val|
        config_data[:col] ||= Hash.new
        symbol_col_name = key.to_sym
        # config_data has not its column data
        unless config_data[:col].has_key?(symbol_col_name)
          # prepare setting to run default seed
          # set nil to seed data
          config_data[:col][symbol_col_name] = nil

          # set type info
          config_data[:type] ||= Hash.new
          config_data[:type][symbol_col_name] = val[:type]

          # set sql_type info
          config_data[:sql_type] ||= Hash.new
          config_data[:sql_type][symbol_col_name] = val[:sql_type]
        end
      end
    end

  end
end