class Logger

  def Logger.log(message)
    Logger.instance.log message
  end

  def Logger.prompt(message)
    Logger.instance.prompt message
  end

  def Logger.header(header)
    Logger.instance.log ""
    Logger.instance.log ("#" * (header.length + 4))
    Logger.instance.log "# #{header} #"
    Logger.instance.log ("#" * (header.length + 4))
  end

  def Logger.subheader(subheader)
    Logger.instance.log ""
    Logger.instance.log subheader
    Logger.instance.log ("-" * subheader.length)
  end

  def Logger.error(error)
    Logger.instance.log("ERROR: #{error}")
  end
  
  def Logger.indent
    Logger.instance.indent
  end

  def Logger.unindent
    Logger.instance.unindent
  end

  def log(message)
    puts (" " * @indent) + message
    self
  end

  def prompt(message)
    print (" " * @indent) + message
    self
  end

  def indent
    @indent += 2
    self
  end

  def unindent
    @indent -= 2
    self
  end

  private

  def initialize
    @indent = 0
  end

  def Logger.instance
    @instance = Logger.new if @instance.nil?
    @instance
  end
  
end
