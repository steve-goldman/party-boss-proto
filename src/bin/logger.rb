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
      if !line.empty?
        Logger.instance.log ("-" * length)
      end
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

  def Logger.set_silent
    Logger.instance.set_silent
  end

  def log(message)
    puts (" " * @indent) + message if !@silent
    self
  end

  def prompt(message)
    print (" " * @indent) + message if !@silent
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

  def set_silent
    @silent = true
  end

  private

  def initialize
    @indent = 0
  end

  @@instance = nil

  def Logger.instance
    @@instance = Logger.new if @@instance.nil?
    @@instance
  end
  
end
