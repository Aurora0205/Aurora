class DataRegister
  class << self
    def regist config_data
      # init maked data
      maked ||= Hash.new
      config_data.each do |key, val|
        model = eval(key)
        table_name = model.table_name
        # col_arr: [:col1, :col2, :col3]
        col_arr = val.first[:col].keys
        
        # each model 
        val.each do |e|
          output_log(e[:log]) 
          # set expand expression for loop '<>' and ':' and so on...
          set_loop_expand_expression(e, maked)
          # if there is no setting data, set default seed data
          set_default_seed(e)
          # seed_arr: [[col1_element, col1_element], [col2_element, col2_element]...]
          seed_arr = get_seed_arr(model, key.to_sym, e, maked)
          
          # optimize is more faster than activerecord-import
          # however, sql.conf setting is necessary to use
          if e[:optimize] 
            # seed_arr.transpose: [[col1_element, col2_element], [col1_element, col2_element]...]
            insert_query = QueryBuilder.insert(table_name, col_arr, seed_arr.transpose)
            ActiveRecord::Base.connection.execute(insert_query)
          else
            model.import(col_arr, seed_arr.transpose, validate: false, timestamps: false)
          end
        end
      end
    end

    private

    def set_default_seed config_data
      block = ->(str){ [:id].include?(str) }
      config_data[:type].each do |key, _|
        # if there is data already, skip
        next if config_data[:col][key.to_sym].present?
        # if it is id, skip
        next if block.call(key)

        config_data[:col][key.to_sym] = 
          Seeder.gen(config_data[:loop], 
                     config_data[:type][key.to_sym], 
                     config_data[:sql_type][key.to_sym]) 
      end
    end
    
    def get_seed_arr model, sym_model, config_data, maked
      options = config_data[:option]
      loop_size = config_data[:loop]

      if apply_autoincrement?(config_data[:autoincrement])
        set_autoincrement(config_data, model, loop_size)
      end

      config_data[:col].map do |key, val| 
        # set expand expression '<>' and ':' and so on...
        set_expand_expression(config_data, key, val, maked)
        # get clone data to use 'maked function' correctly
        # if it doesn't use clone, will be received destructive effect by rotate!
        expanded_val = config_data[:col][key].clone
        option_conf = options.nil? ? nil : Option.gen(options[key])
        seed_data = 
          loop_size.times.map.with_index do |_, idx|
            option_conf.nil? ? get_seed(expanded_val, idx) : get_seed_with_option(expanded_val, option_conf, idx)
          end
          
        update_maked_data(maked, sym_model, key, seed_data)

        seed_data
      end
    end

    def apply_autoincrement? autoincrement_flg
      # default true
      return true if autoincrement_flg.nil?
      autoincrement_flg
    end

    def set_autoincrement config_data, model, loop_size
      last_record = model.last
      # use pluck to optimize(suppress make object)
      additions = model.all.pluck(:id).size + loop_size      
      latest_id = last_record.nil? ? 1 : last_record.id + 1
      config_data[:col][:id] = [*latest_id..additions]
    end

    def set_expand_expression config_data, key, val, maked
      # if it exists type, there is no need for doing 'expand expression'
      return if config_data[:type][key].present?
      config_data[:col][key] = ExpressionParser.parse(val, maked)
    end

    def set_loop_expand_expression config_data, maked
      config_data[:loop] = 
        LoopExpressionParser.parse(config_data[:loop], maked)  
    end

    def get_seed arr, cnt
      # default return rotate
      return arr.first if cnt.zero?
      arr.rotate!(1).first
    end

    def get_seed_with_option arr, option, cnt
      Option.apply(arr, option, cnt)
    end

    def update_maked_data maked, sym_model, col, seed
      # maked: { key: Model, value: {key: col1, val: [col1_element, col1_element]} }
      maked[sym_model] ||= Hash.new
      if maked[sym_model].has_key?(col)
        # merge hash data
        maked[sym_model][col] += seed
      else
        maked[sym_model][col] = seed
      end
    end

    def output_log log
      return if log.nil?
      puts log
    end

  end
end