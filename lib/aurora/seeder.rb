class Seeder 
  class << self
    def gen n, type, sql_type
      return make_array(n, ->(){ rand(100) }) if type == "integer"
      return make_array(n, ->(){ rand(0.0..100.0) }) if type == "float"
      return make_array(n, ->(){ rand(0.0..1_000_000_000.0) }) if type == "decimal"
      return make_array(n, ->(){ SecureRandom.hex(300) }) if ["text", "binary"].include?(type)
      # for tiny int
      return make_array(n, ->(){ [1, 0].sample }) if type == "boolean"
      return make_string_array(n, sql_type) if type == "string"
      return make_datetime_array() if ["datetime", "date", "time"].include?(type)
    end

    private

    def make_array n, proc
      Array.new(n).map{ proc.call() }
    end

    def make_datetime_array
      [Time.now.to_s(:db)]
    end

    def make_string_array n, sql_type
      if is_enum?(sql_type)
        # convert enum('e1', 'e2', 'e3') to ["e1", "e2", "e3"]
        return sql_type[5..-2].gsub("'", "").split(",")
      else
        return Array.new(n).map{  SecureRandom.hex(20) }
      end
    end
  end
end