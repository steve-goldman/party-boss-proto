require_relative 'game_engine'

options = {
  input_file: nil,
  output_file: nil,
  num_cycles: 1,
  boss_A: "HUMAN",
  boss_B: "HUMAN",
}

opt_parser = OptionParser.new do |opts|
  
  opts.on("-i", "--input-file FILE",
          "JSON file to load game state from") do |file|
    options[:input_file] = file
  end
  
  opts.on("-o", "--output-file FILE",
          "JSON file to write game state to") do |file|
    options[:output_file] = file
  end
  
  opts.on("-n", "--num-cycles NUM",
          "How many new cycles to play, default #{options[:num_cycles]}") do |num_cycles|
    options[:num_cycles] = num_cycles
  end

  opts.on("-A", "--boss-A HUMAN|AI",
          "Human or AI control for boss A, default is #{options[:boss_A]}") do |boss_A|
    options[:boss_A] = boss_A
  end
  
  opts.on("-B", "--boss-B HUMAN|AI",
          "Human or AI control for boss B, default is #{options[:boss_B]}") do |boss_B|
    options[:boss_B] = boss_B
  end

  opts.on("-s", "--silent",
          "Suppress screen output") do |silent|
    Logger.set_silent
  end
  
  opts.on("-p", "--page",
          "Suppress 'page' input") do |silent|
    Logger.no_page
  end
  
end

opt_parser.parse!

engine = GameEngine.new(options)

game = engine.run(options[:num_cycles].to_i)

game.to_file(options[:output_file]) if !options[:output_file].nil?
