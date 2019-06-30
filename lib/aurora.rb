require "aurora/data_register/data_register.rb"
require "aurora/data_structure/data_structure.rb"
require "aurora/expression_parser/expression_parser.rb"
require "aurora/loader/loader.rb"
require "aurora/option/option.rb"
require "aurora/seeder/seeder.rb"
require "aurora/regex.rb"
require "activerecord-import"
require "tomlrb"

module Aurora
  class NotFoundLoader < StandardError; end

  class << self
    def execute filepath
      contents = load_file(filepath)
      data = DataStructure.gen(contents)
      DataRegister.regist(data)
    end

    private
    def load_file filepath
      case File.extname(filepath)
      when ".toml"
        return TomlLoader.load(filepath)
      when ".yml"
        # convert 'str_key' to 'symbol_key'
        contents =
          YmlLoader.load(filepath).each do |e|
            e.deep_symbolize_keys!
          end

        return contents.inject(:merge)
      else
        raise NotFoundLoader.new("not found loader")
      end
    end

  end
end
