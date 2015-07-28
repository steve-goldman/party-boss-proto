class Logger

  def Logger.log(message)
    Logger.instance.log message
  end

  def Logger.header(header)
    Logger.instance.log ("#" * (header.length + 4))
    Logger.instance.log "# #{header} #"
    Logger.instance.log ("#" * (header.length + 4))
  end

  def Logger.subheader(subheader)
    Logger.instance.log subheader
    Logger.instance.log ("-" * subheader.length)
  end
  
  def Logger.indent
    Logger.instance.indent
  end

  def Logger.unindent
    Logger.instance.unindent
  end

  def log(message)
    puts (" " * @indent) + message
  end

  def indent
    @indent += 2
  end

  def unindent
    @indent -= 2
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
