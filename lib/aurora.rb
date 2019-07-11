Dir[File.expand_path('../aurora', __FILE__) << '/*.rb'].each do |file|
  require file
end
require "activerecord-import"

module Aurora
  class NotFoundLoader < StandardError; end

  class << self
    def execute filepath
      contents = load_file(filepath)
      data = DataStructure.gen(contents)
      DataRegister.regist(data)
    end

    def import filepath
      AdditionalMethods.import(filepath)
    end

    def reset
      AdditionalMethods.remove()
    end

    private
    def load_file filepath
      case File.extname(filepath)
      when ".toml"
        return TomlLoader.load(filepath)
      when ".yml"
        return YmlLoader.load(filepath)
      else
        raise NotFoundLoader.new("not found loader")
      end
    end

  end
end
