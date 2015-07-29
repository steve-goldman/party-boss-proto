# makes json from politician records that look like:
#   name fundraising economy defense social

require 'json'

array = STDIN.read.split("\n").map do |line|
  tokens = line.split(/\s+/)
  {
    name: tokens[0..1].join(' '),
    fundraising: tokens[2].to_i,
    strengths: {
      economy: tokens[3].to_i,
      defense: tokens[4].to_i,
      social: tokens[5].to_i
    }
  }
end

File.open(ARGV[0] || 'data/politicians.json', "w") do |file|
  file.write(JSON.pretty_generate(array) + "\n")
end
