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

class YmlLoader < FileLoader
  class << self
    def load filepath
      YAML.load_file(filepath)
    end
  end
end