class Seeder 
  class << self
    def gen n, type
      return make_array(n, ->(){ SecureRandom.hex(20) }) if type == "string"
      return make_array(n, ->(){ rand(100) }) if type == "integer"
      return make_array(n, ->(){ rand(0.0..100.0) }) if type == "float"
      return make_array(n, ->(){ rand(0.0..1_000_000_000.0) }) if type == "decimal"
      return make_array(n, ->(){ SecureRandom.hex(300) }) if ["text", "binary"].include?(type)
      return make_array(n, ->(){ [true, false].sample }) if type == "boolean"
      return make_datetime_array() if ["datetime", "date", "time"].include?(type)
    end

    private

    def make_array n, proc
      Array.new(n).map{ proc.call() }
    end

    def make_datetime_array
      [DateTime.now]
    end
  end
end