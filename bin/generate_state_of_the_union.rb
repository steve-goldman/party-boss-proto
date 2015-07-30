# makes json from politician records that look like:
#   issue first second third

require 'json'

array = STDIN.read.split("\n").map do |line|
  tokens = line.split(/\s+/)
  {
    issue: tokens[0..(tokens.length - 4)].join(' '),
    priorities: [
      tokens[tokens.length - 3].downcase,
      tokens[tokens.length - 2].downcase,
      tokens[tokens.length - 1].downcase
    ]
  }
end

File.open(ARGV[0] || 'data/state_of_the_unions.json', "w") do |file|
  file.write(JSON.pretty_generate(array) + "\n")
end
