require_relative '../objects/config'
require_relative '../objects/game_state'
require_relative 'logger'

class HumanBoss

  def initialize(party, hand)
    @party = party
    @hand = hand
  end

  def get_candidates(game_state)
    while true
      # don't spoil the data until the user confirms
      temp_politicians = @hand.politicians.clone
      # get the candidates from the user
      i = 0
      candidates = game_state.board.office_holders.map do |office_holder|
        i += 1
        Logger.subheader("Selecting candidate for race ##{i}").indent
        if @party == office_holder.party.to_sym
          Logger.log("Encumbent #{office_holder.politician} is in your party").unindent
          office_holder.politician
        else
          Logger.log "Candidate to run against #{office_holder.politician}"
          input_from_array temp_politicians, true
        end
      end
      # ask user to confirm
      if confirm_candidates game_state.board.office_holders, candidates
        return candidates
      end
    end
  end

  def get_bills
    while true
      # don't spoil the data until the user confirms
      temp_bills = @hand.bills.clone
      # get the bills from the user
      bills = Config.get.bills_num_on_floor.times.map do |index|
        Logger.subheader("Selecting bill for floor matchup ##{index + 1}").indent
        input_from_array(temp_bills, true)
      end
      # ask user to confirm
      if confirm_bills bills
        return bills
      end
    end
  end

  def get_tactic(legislative_session)
    if @hand.tactics.empty?
      Logger.subheader("No tactics to choose from")
      return [Tactic::Pass, nil, nil]
    end
    while true
      Logger.subheader("Select tactic").indent
      tactic = input_from_array(@hand.tactics, false, true)
      if tactic.nil?
        return [Tactic::Pass, nil, nil]
      end
      if tactic.filibuster?
        if confirm_filibuster
          return [tactic, nil, nil]
        end
      else
        Logger.subheader("Select floor matchup").indent
        index = input_floor_matchup_index(legislative_session)
        Logger.indent
        party = input_party(tactic)
        if confirm_tactic(legislative_session, tactic, index, party)
          return [tactic, index, party]
        end
      end
    end
  end

  def get_allocation(total_dice, matchup_descriptions)
    while true
      Logger.subheader("Distribute #{total_dice} dice").indent
      allocation = matchup_descriptions.map do |matchup_description|
        input_allocation matchup_description
      end
      Logger.unindent
      if allocation.reduce(:+) > total_dice
        Logger.error("Total dice must not exceed #{total_dice}")
      elsif confirm_allocation allocation, total_dice, matchup_descriptions
        return DiceAllocation.new allocation
      end
    end
  end

  def get_choice(options)
    while true
      Logger.subheader("Select from the following:").indent
      options.each_index do |index|
        Logger.log("#{index + 1}: #{options[index]}")
      end
      Logger.prompt("(Enter #): ")
      input = gets.chomp
      Logger.unindent
      if !int_in_range? input, 1, options.count
        Logger.error("Input #{input} is out of range")
      else
        return (input.to_i - 1) if confirm
      end
    end
  end

  def get_bill(mask_out_bills)
    temp_bills = @hand.bills.select do |bill|
      mask_out_bills.select { |mask_bill| mask_bill.equals?(bill) }.empty?
    end
    while true
      bill = input_from_array(temp_bills, false)
      if confirm_bills [bill]
        return bill
      end
    end
  end

  private

  def input_from_array(options, remove, zero_okay = false)
    # show the list
    options.count.times do |index|
      Logger.log "#{index + 1}: #{options[index]}"
    end
    # get the input
    while true
      Logger.prompt "(Enter ##{zero_okay ? ' or 0 for none' : ''}): "
      input = gets.chomp
      if input == "0" && zero_okay
        Logger.unindent
        return nil
      elsif !int_in_range? input, 1, options.count
        Logger.error "Input #{input} is out of range"
      else
        elem = options[input.to_i - 1]
        options.delete_at(input.to_i - 1) if remove
        Logger.unindent
        return elem
      end
    end
  end

  def input_floor_matchup_index(legislative_session)
    # show the list
    Config.get.bills_num_on_floor.times do |index|
      Logger.log "#{index + 1}: #{legislative_session.get_bill_on_floor(index, :A)} | #{legislative_session.get_bill_on_floor(index, :B)}"
    end

    while true
      Logger.prompt "(Enter #): "
      input = gets.chomp
      if !int_in_range? input, 1, Config.get.bills_num_on_floor
        Logger.error "Input #{input} is out of range"
      else
        Logger.unindent
        return input.to_i - 1
      end
    end
  end

  def input_party(tactic)
    play_on_party = tactic.must_play_on_party(@party)
    if !play_on_party.nil?
      whose = (play_on_party == @party) ? "your" : "your opponent's"
      Logger.log("(Enter party's bill A/B): #{play_on_party} (forced)").unindent
      return play_on_party
    end
    while true
      Logger.prompt "(Enter party's bill A/B): "
      input = gets.chomp.upcase
      if input != :A && input != :B
        Logger.error "Input #{input} is invalid"
      else
        Logger.unindent
        return input
      end
    end
  end

  def confirm_candidates(office_holders, candidates)
    Logger.subheader("You have selected:").indent
    Config.get.seats_num.times do |index|
      if office_holders[index].politician == candidates[index]
        Logger.log "#{candidates[index]} (encumbent)"
      else
        Logger.log "#{candidates[index]} versus #{office_holders[index].politician}"
      end
    end
    Logger.unindent
    confirm
  end

  def confirm_bills(bills)
    Logger.subheader("You have selected:").indent
    Config.get.bills_num_on_floor.times do |index|
      Logger.log "#{bills[index]}"
    end
    Logger.unindent
    confirm
  end

  def confirm_tactic(legislative_session, tactic, index, party)
    Logger.subheader("You have selected:").indent
    Logger.log "#{tactic}"
    Logger.log "#{legislative_session.get_bill_on_floor(index, :A)} | #{legislative_session.get_bill_on_floor(index, :B)}"
    Logger.log "Party '#{party}'s bill"
    Logger.unindent
    confirm
  end

  def confirm_filibuster
    Logger.subheader("You have selected filibuster")
    confirm
  end

  def input_allocation(matchup_description)
    while true
      Logger.log "#{matchup_description}"
      Logger.prompt "(Enter number of dice): "
      num_dice = gets.chomp.downcase
      if !int_in_range? num_dice, 0, 999999
        Logger.error "#{num_dice} is out of range"
      else
        return num_dice.to_i
      end
    end
  end

  def confirm_allocation(allocation, total_dice, matchup_descriptions)
    Logger.subheader("You have allocated:").indent
    matchup_descriptions.each_index do |index|
      Logger.log "#{allocation[index]} for #{matchup_descriptions[index]}"
    end
    Logger.log "#{total_dice - allocation.reduce(:+)} left over"
    Logger.unindent
    return confirm
  end

  def confirm
    while true
      Logger.prompt "(Confirm? y/n): "
      choice = gets.chomp
      if choice.downcase == 'y'
        return true
      elsif choice.downcase == 'n'
        return false
      end
      Logger.error "#{choice} is not valid"
    end
  end

  def int_in_range?(input, min, max)
    return input =~ /^[0-9]+$/ && input.to_i >= min && input.to_i <= max
  end
    
end
