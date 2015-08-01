# makes json from politician records that look like:
#   title agenda sector vp

require 'json'

array = STDIN.read.split("\n").map do |line|
  tokens = line.split(/\s+/)
  {
    title: tokens[0..(tokens.length - 4)].join(' '),
    agenda: tokens[tokens.length - 3].downcase,
    sector: tokens[tokens.length - 2].downcase,
    vps: tokens[tokens.length - 1].to_i
  }
end

File.open(ARGV[0] || 'data/bills.json', "w") do |file|
  file.write(JSON.pretty_generate(array) + "\n")
end
