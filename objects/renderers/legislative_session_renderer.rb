require_relative '../legislative_session'

class LegislativeSessionRenderer < Renderer

  Passes = "PASSES"
  DoesNotPass = "DOES NOT PASS"
  
  def initialize
    super(Bill::MaxLength + [Passes.length, DoesNotPass.length].max + 1)
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
      results(legislative_session, board), underline,
      bills_dealt(legislative_session),    underline
    ].join("\n")
  end

  private

  def results(legislative_session, board)
    Config.get.bills_num_on_floor.times.map { |index|
      [
        two_sides(passed(legislative_session, index, 'A'),
                  passed(legislative_session, index, 'B')),
        two_sides(outcomes(legislative_session, index, 'A'),
                  outcomes(legislative_session, index, 'B')),
        two_sides(vps(legislative_session, board, index, 'A'),
                  vps(legislative_session, board, index, 'B'))
      ]
    }.flatten.join("\n")
  end

  def passed(legislative_session, index, party)
    bill = legislative_session.send("bills_#{party}")[index]
    passes = legislative_session.passes?(index, party) ? Passes : DoesNotPass
    "#{bill} #{passes}"
  end

  def outcomes(legislative_session, index, party)
    outcomes = legislative_session.send("outcomes_#{party}")[index]
    "  #{outcomes}"
  end

  def vps(legislative_session, board, index, party)
    vps = legislative_session.vps(index, party, board)
    legislative_session.passes?(index, party) ? "  #{vps} vps" : ""
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

end
