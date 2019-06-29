require "loader/loader.rb"
require "data_structure/data_structure.rb"
require "data_register/data_register.rb"

module Aurora
  class << self
    def execute filepath
      contents = TomlLoader.load(filepath)
      data = DataStructure.gen(contents)
      DataRegister.regist(data)
    end
  end
end
