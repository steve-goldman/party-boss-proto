require_relative 'base_object'

class Config < BaseObject

  # define the data that goes in this object
  Members = [
    { name: :politicians_num_in_party, type: Integer },
  ]

  def Config.get(filename = 'data/config.json')
    throw "asking for #{filename} but already loaded #{@filename}" if
      @filename && @filename != filename

    if @instance.nil?
      @instance = Config.from_file filename
      @filename = filename
    end

    @instance
  end

end
