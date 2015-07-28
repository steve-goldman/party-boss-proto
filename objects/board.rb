require_relative '../lib/class_record'
require_relative '../lib/serializable'
require_relative '../lib/deserializable'

require_relative 'state_of_the_union'
require_relative 'office_holder'

class Board

  # define the data that goes in this object
  Members = [
    { name: :state_of_the_union, type: StateOfTheUnion },
    { name: :office_holders,     type: OfficeHolder, is_array: true },
  ]

  # to get the constructor and member accessors
  include ClassRecord

  # to get instance.serialize
  include Serializable

  # to get Class.deserialize
  extend Deserializable

  def num_campaign_dice(candidates)
    candidates.reduce(0) do |sum, candidate|
      sum + candidate.fundraising + (office_holder?(candidate) ? 1 : 0)
    end
  end

  private

  def office_holder?(candidate)
    office_holders.reduce(false) do |result, office_holder|
      result || candidate == office_holder.politician
    end 
  end
  
end
