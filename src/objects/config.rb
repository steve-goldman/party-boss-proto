require_relative 'base_object'

class Config < BaseObject

  # define the data that goes in this object
  Members = [
    { name: "seats_num",                    type: Integer },
    { name: "politicians_num_in_party",     type: Integer },
    { name: "bills_num_in_committee",       type: Integer },
    { name: "bills_num_on_floor",           type: Integer },
    { name: "fundraising_dice_max",         type: Integer },
    { name: "leadership_dice_max",          type: Integer },
    { name: "tactics_num_initial",          type: Integer },
    { name: "tactics_num_per_campaign_die", type: Integer },
    { name: "bill_sunset_num_cycles",       type: Integer },
  ]

  @@instance = nil
  @@filename = nil
  
  def Config.get(filename = 'src/data/config.json')
    throw "asking for #{filename} but already loaded #{@@filename}" if
      @@filename && @@filename != filename

    if @@instance.nil?
      @@instance = Config.from_file filename
      @@filename = filename
    end

    @@instance
  end

end
