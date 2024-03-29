class DataRegister
  class << self
    def regist data
      # init maked to accumulate maded data
      maked = Hash.new
      # init model_data to cache data of model
      model_data = Hash.new
      data.each do |e|
        str_model = e.first
        cache_model_data(model_data, str_model)
        # e.second is config_data
        config_data = e.second
        # col_arr: [:col1, :col2, :col3]
        col_arr = config_data[:col].keys

        # set expand expression for loop '<>' and ':' and so on...
        set_loop_expand_expression(config_data, maked)
        # if there is no setting data, set default seed data
        set_default_seed(config_data)
        # seed_arr: [[col1_element, col1_element], [col2_element, col2_element]...]
        seed_arr = 
          get_seed_arr(model_data[str_model][:model], 
                       model_data[str_model][:sym_model], config_data, maked)

        # execute insert
        output_log(config_data[:log]) 
        execute(model_data[str_model][:model], 
                config_data, model_data[str_model][:table_name], col_arr, seed_arr)
      end
    end

    private

    def execute model, config_data, table_name, col_arr, seed_arr
      # optimize is more faster than activerecord-import
      # however, sql.conf setting is necessary to use
      if config_data[:optimize] 
        # seed_arr.transpose: [[col1_element, col2_element], [col1_element, col2_element]...]
        insert_query = QueryBuilder.insert(table_name, col_arr, seed_arr.transpose)
        ActiveRecord::Base.connection.execute(insert_query)
      else
        model.import(col_arr, seed_arr.transpose, validate: config_data[:validate], timestamps: false)
      end
    end

    def cache_model_data model_data, str_model
      return if model_data[str_model].present?
      
      model = eval(str_model)
      model_data[str_model] = {
        model: model,
        sym_model: str_model.to_sym,
        table_name: model.table_name
      }
    end

    def set_default_seed config_data
      block = ->(symbol){ :id == symbol }
      # each column type, key is symbolize column name
      config_data[:type].each do |key, _|
        # if it is id, skip
        next if block.call(key)
        # if there is data already, skip
        next if config_data[:col][key].present?

        config_data[:col][key] = Seeder.gen(config_data, key) 
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
        # Take count yourself, because .with_index is slow
        cnt = 0
        seeds = 
          loop_size.times.map do
            seed = option_conf.nil? ? get_seed(expanded_val, cnt) : get_seed_with_option(expanded_val, option_conf, cnt)
            cnt += 1

            seed
          end
        update_maked_data(maked, sym_model, key, seeds)

        seeds
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
      get_rotated_val(arr, cnt)
    end

    def get_seed_with_option arr, option, cnt
      Option.apply(arr, option, cnt)
    end

    def update_maked_data maked, sym_model, col, seed
      # maked: { key: Model, value: {key: col1, val: [col1_element, col1_element]} }
      maked[sym_model] ||= Hash.new
      maked[sym_model][col] = seed
    end

    def output_log log
      return if log.nil?
      puts log
    end

  end
end