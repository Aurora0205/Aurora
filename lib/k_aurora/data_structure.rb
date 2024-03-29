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
      foreign_key_data = get_foreign_key_data(model)
      
      config_data[:col] ||= Hash.new    
      model.columns.each do |e|
        symbol_col_name = e.name.to_sym

        unless exists_seed_data?(config_data, symbol_col_name)
          # prepare setting to run default seed
          # set nil to seed data
          config_data[:col][symbol_col_name] = nil

          # set type info
          config_data[:type] ||= Hash.new
          config_data[:type][symbol_col_name] = e.type.to_s

          # set enum info
          config_data[:enum] ||= Hash.new
          if is_enum?(e.sql_type.to_s)
            config_data[:enum][symbol_col_name] = 
              e.sql_type.to_s[5..-2].tr("'", "").split(",")
          end

          # set foreign_key info
          config_data[:foreign_key] ||= Hash.new
          if is_foreign_key?(symbol_col_name, foreign_key_data)
            config_data[:foreign_key][symbol_col_name] = foreign_key_data[symbol_col_name]
          end
        end
      
      end
    end

    def get_foreign_key_data model
      associations = model.reflect_on_all_associations(:belongs_to)
      return { } if associations.empty?
      associations.reduce(Hash.new)do |acc, r|
        acc[r.foreign_key.to_sym] = eval(r.name.to_s.classify)

        acc
      end
    end

    def is_foreign_key? symbol_col_name, foreign_key_data
      foreign_key_data[symbol_col_name].present?
    end

    def exists_seed_data? config_data ,symbol_col_name
      config_data[:col].has_key?(symbol_col_name)
    end
    
    ENUM = /^enum(\s*.)*$/
    def is_enum? val
      return false unless val.kind_of?(String)
      ENUM =~ val 
    end
  end
end