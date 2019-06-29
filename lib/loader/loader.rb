require "tomlrb"

class FileLoader
  class << self
    # load data with the use of indicated filepath 
    def load filepath
    end
  end
end

class TomlLoader < FileLoader
  class << self
    def load filepath
      Tomlrb.load_file(filepath, symbolize_keys: true)
    end
  end
end