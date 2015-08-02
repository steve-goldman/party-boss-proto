require_relative '../legislative_session'

class LegislativeSessionRenderer < Renderer

  Passes = "PASSES"
  DoesNotPass = "DOES NOT PASS"
  
  def initialize
    super(Bill::MaxLength)
  end
  
  @@instance = nil

  def LegislativeSessionRenderer.get
    @@instance = LegislativeSessionRenderer.new if @@instance.nil?
    @@instance
  end
  
  def render(legislative_session, board)
    [
      "Legislation results",               underline,
      party_header,                        underline,
      results(legislative_session, board),
      bills_dealt(legislative_session),    underline
    ].join("\n")
  end

  def render_bills_on_floor(legislative_session)
    [
      "Bills on the floor", underline,
      party_header,         underline,
    ].concat(
      Config.get.bills_num_on_floor.times.map { |index| bill_matchup(legislative_session, index) }
    ).join("\n")
  end

  private

  def results(legislative_session, board)
    Config.get.bills_num_on_floor.times.map { |index|
      [
        two_sides(legislative_session.bills_A[index],
                  legislative_session.bills_B[index]),
        two_sides(passed(legislative_session, index, 'A'),
                  passed(legislative_session, index, 'B')),
        two_sides(outcomes(legislative_session, index, 'A'),
                  outcomes(legislative_session, index, 'B')),
        two_sides(vps(legislative_session, board, index, 'A'),
                  vps(legislative_session, board, index, 'B')),
        underline,
      ]
    }.join("\n")
  end

  def passed(legislative_session, index, party)
    legislative_session.passes?(index, party) ? Passes : DoesNotPass
  end

  def outcomes(legislative_session, index, party)
    outcomes = legislative_session.send("outcomes_#{party}")[index]
    "#{outcomes}"
  end

  def vps(legislative_session, board, index, party)
    vps = legislative_session.vps(index, party, board)
    "#{vps} vps"
  end

  def bills_dealt(legislative_session)
    [
      "Bills dealt", underline,
    ].concat(
      [legislative_session.bills_dealt_A.count,
       legislative_session.bills_dealt_B.count].max.times.map { |index|
        two_sides(index < legislative_session.bills_dealt_A.count ?
                    legislative_session.bills_dealt_A[index] : "",
                  index < legislative_session.bills_dealt_B.count ?
                    legislative_session.bills_dealt_B[index] : "")
      }
    ).join("\n")
  end

  def bill_matchup(legislative_session, index)
    tactics_A = []
    tactics_B = []
    legislative_session.tactics.each do |played_tactic|
      if played_tactic.bill_A.equals?(legislative_session.bills_A[index])
        (played_tactic.party_played_on == 'A' ? tactics_A : tactics_B).push(
          "#{played_tactic.tactic} played by '#{played_tactic.party_played_by}'")
      end
    end
    if tactics_A.empty? && tactics_B.empty?
      [
        two_sides(legislative_session.bills_A[index], legislative_session.bills_B[index]),
        underline
      ].join("\n")
    else
      [
        two_sides(legislative_session.bills_A[index], legislative_session.bills_B[index]),
        underline
      ]
        .concat([tactics_A.count, tactics_B.count].max.times.map { |index|
                  two_sides(index < tactics_A.count ? tactics_A[index] : "",
                            index < tactics_B.count ? tactics_B[index] : "") })
        .concat([underline])
        .join("\n")
    end
  end
end
