require_relative '../election'

class ElectionRenderer < Renderer

  Passes = "PASSES"
  DoesNotPass = "DOES NOT PASS"
  
  def initialize
    super(Politician::MaxLength)
  end
  
  @@instance = nil

  def ElectionRenderer.get
    @@instance = ElectionRenderer.new if @@instance.nil?
    @@instance
  end
  
  def render(election, board)
    [
      "Election results",          underline,
      party_header(board),         underline,
      results(election, board),
      politicians_dealt(election), underline,
      tactics_dealt(election)
    ].join("\n")
  end

  def render_matchups(board, candidates_A, candidates_B)
    [
      "Election matchups", underline,
      party_header(board), underline,
    ].concat(
      Config.get.seats_num.times.map { |index|
        two_sides(candidates_A[index], candidates_B[index])
      }
    ).join("\n")
  end

  private

  Wins  = "WINS "
  Loses = "LOSES"
  
  def results(election, board)
    Config.get.seats_num.times.map { |index|
      [
        two_sides(election.candidates_A[index],
                  election.candidates_B[index]),
        two_sides(win_lose(election, index, board, :A),
                  win_lose(election, index, board, :B)),
        two_sides(points_breakdown(election, index, board, :A),
                  points_breakdown(election, index, board, :B)),
        underline,
      ]
    }.join("\n")
  end

  def win_lose(election, index, board, party)
    election.get_result(index, board)[:winning_party] == party ? Wins : Loses
  end

  def points_breakdown(election, index, board, party)
    [
      election.points(index, board, party),
      '=',
      election.strength_points(index, board, party),
      '+',
      election.send("outcomes_#{party}")[index]
    ].join(' ')
  end

  def politicians_dealt(election)
    [
      "Politicians dealt", underline,
    ].concat(
      [election.politicians_dealt_A.count,
       election.politicians_dealt_B.count].max.times.map { |index|
        two_sides(index < election.politicians_dealt_A.count ?
                    election.politicians_dealt_A[index] : "",
                  index < election.politicians_dealt_B.count ?
                    election.politicians_dealt_B[index] : "")
      }
    ).join("\n")
  end

  def tactics_dealt(election)
    [
      "Tactics dealt", underline,
    ].concat(
      [election.tactics_dealt_A.count,
       election.tactics_dealt_B.count].max.times.map { |index|
        two_sides(index < election.tactics_dealt_A.count ?
                    election.tactics_dealt_A[index] : "",
                  index < election.tactics_dealt_B.count ?
                    election.tactics_dealt_B[index] : "")
      }
    ).join("\n")
  end

end
