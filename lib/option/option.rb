class Option
  class << self

    def gen option
      # shape option data
      # [option1, option2] => { select: [option2], add: [option1] }
      # [] => { select: [], add: [] }
      option.nil? ? { select: [], add: [] }: separate(option)
    end

    def apply arr, option_conf, cnt = 0
      selected_val = select(option_conf[:select].first, arr, cnt)
      add(option_conf[:add].first, selected_val, cnt)
    end


    private

    def separate option
      # separate option to 'select' and 'add'
      # { select = >[], add => [] }
      select_filter = ->(name){ ["rotate", "random"].include?(name) }
      add_filter = ->(name){ ["add_id"].include?(name) }

      {
        select: option.select{|s| select_filter.call(s)},
        add: option.select{|s| add_filter.call(s)}
      }
    end

    def select option, arr, cnt
      return arr.sample if option == "random"

      # default return rotate
      arr.rotate(cnt).first
    end

    def add option, val, cnt
      return val += "_#{cnt}" if option == "add_id"

      val
    end
  end
end