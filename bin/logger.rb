class Logger

  def Logger.log(message)
    message.split("\n").each do |line|
      Logger.instance.log line
    end
    Logger.instance
  end

  def Logger.prompt(message)
    Logger.instance.prompt message
  end

  def Logger.header(header)
    lines = header.split(/\n/)
    length = lines.reduce(0) { |max, line| [max, line.length].max }
    Logger.instance.log ""
    Logger.instance.log ("#" * (length + 4))
    lines.each do |line|
      Logger.instance.log(sprintf "# %-#{length}s #", line)
    end
    Logger.instance.log ("#" * (length + 4))
  end

  def Logger.subheader(subheader)
    lines = subheader.split(/\n/)
    length = lines.reduce(0) { |max, line| [max, line.length].max }
    Logger.instance.log ""
    lines.each do |line|
      Logger.instance.log line
      Logger.instance.log ("-" * length)
    end
    Logger.instance
  end
  
  def Logger.error(error)
    error.split(/\n/).each do |line|
      Logger.instance.log("ERROR: #{line}")
    end
    Logger.instance
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
