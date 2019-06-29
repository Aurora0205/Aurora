require "option/option.rb"
require "activerecord-import"

class DataRegister
  class << self
    def regist config_data
      config_data.each do |key, val|
        str_model = key.to_s
        model = eval(str_model)
        col_arr = val.first[:col].keys

        val.each do |e|
          output_log(e[:log]) 
          seed_arr = get_seed_arr(model, e)
          # about data structure
          # col_arr: [:col1, :col2, :col3]
          # seed_arr: [[col1_element, col1_element], [col2_element, col2_element]...]
          # transpose => seed_arr: [[col1_element, col2_element], [col1_element, col2_element]...]
          model.import(col_arr, seed_arr.transpose, validate: false, timestamps: false)
        end

      end
    end

    def get_seed_arr model, config_data
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

    def get_seed arr, cnt
      arr.rotate(cnt).first
    end

    def get_seed_with_option arr, option, cnt
      Option.apply(arr, option, cnt)
    end

    def output_log log
      return if log.nil?
      puts log
    end

  end
end