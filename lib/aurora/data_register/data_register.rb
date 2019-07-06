class DataRegister
  class << self
    def regist config_data
      # init maked data
      maked ||= Hash.new
      config_data.each do |key, val|
        model = eval(key)
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
          seed_arr = get_seed_arr(model, e, maked)
          # seed_arr.transpose: [[col1_element, col2_element], [col1_element, col2_element]...]
          model.import(col_arr, seed_arr.transpose, validate: false, timestamps: false)

          update_maked_data(maked, key.to_sym, col_arr, seed_arr)
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
    
    def get_seed_arr model, config_data, maked
      # set expand expression '<>' and ':' and so on...
      set_expand_expression(config_data, maked)

      options = config_data[:option]
      loop_size = config_data[:loop]

      if apply_autoincrement?(config_data[:autoincrement])
        set_autoincrement(config_data, model, loop_size)
      end

      config_data[:col].map do |key, val| 
        option_conf = options.nil? ? nil : Option.gen(options[key])
        loop_size.times.map.with_index do |_, idx|
          option_conf.nil? ? get_seed(val, idx) : get_seed_with_option(val, option_conf, idx)
        end
      end
    end

    def apply_autoincrement? autoincrement_flg
      # default true
      return true if autoincrement_flg.nil?
      autoincrement_flg
    end

    def set_autoincrement config_data, model, loop_size
      last_record = model.last
      additions = model.all.count + loop_size
      latest_id = last_record.nil? ? 1 : last_record.id + 1
      config_data[:col][:id] = [*latest_id..additions]
    end

    def set_expand_expression config_data, maked
      config_data[:col].each do |key, val|
        # if it exists type, there is no need for doing 'expand expression'
        next if config_data[:type][key.to_sym].present?
        config_data[:col][key.to_sym] = ExpressionParser.parse(val, maked)
      end
    end

    def set_loop_expand_expression config_data, maked
      config_data[:loop] = 
        LoopExpressionParser.parse(config_data[:loop], maked)  
    end

    def get_seed arr, cnt
      arr.rotate(cnt).first
    end

    def get_seed_with_option arr, option, cnt
      Option.apply(arr, option, cnt)
    end

    def update_maked_data maked, sym_model, col_arr, seed_arr
      # maked: { key: Model, value: {key: col1, val: [col1_element, col1_element]} }
      if maked.has_key?(sym_model)
        # merge hash data
        maked[sym_model].merge!([col_arr, seed_arr].transpose.to_h)do |_, oldval, newval|
          oldval + newval
        end
      else
        maked[sym_model] = [col_arr, seed_arr].transpose.to_h
      end

      maked
    end

    def output_log log
      return if log.nil?
      puts log
    end

  end
end