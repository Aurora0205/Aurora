class DataStructure
  class << self
    def gen data
      data.reduce([]) do |acc, r|
        # r.second is block_data, like { Pref: {loop: 3}, Member: {loop: 3}... }
        gen_structure(acc, r.second)
      end
    end

    private

    def gen_structure gen_acc, block_data
      block_data.reduce(gen_acc) do |acc, r|
        # r[0] is symbolize model
        # convert symbol to string
        r[0] = r[0].to_s

        # r.second is config_data, like {loop: 3, ...}
        set_col_type(r.second, r[0])

        acc.push(r)
      end
    end

    def set_col_type config_data, str_model
      model = eval(str_model)
      config_data[:col] ||= Hash.new    
      model.columns.each do |e|
        symbol_col_name = e.name.to_sym

        # config_data has not its column data
        unless config_data[:col].has_key?(symbol_col_name)
          # prepare setting to run default seed
          # set nil to seed data
          config_data[:col][symbol_col_name] = nil

          # set type info
          config_data[:type] ||= Hash.new
          config_data[:type][symbol_col_name] = e.type.to_s

          # set sql_type info
          config_data[:sql_type] ||= Hash.new
          config_data[:sql_type][symbol_col_name] = e.sql_type.to_s
        end
      
      end
    end

  end
end