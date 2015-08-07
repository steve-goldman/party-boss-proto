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
  
  def Config.get(config = nil)
    throw "asking for config but already loaded" if
      !@@instance.nil? && !config.nil?

    if @@instance.nil?
      @@instance = config.nil? ? Config.from_file(DefaultFilename) : config
    end

    @@instance
  end

  private

  DefaultFilename = 'src/data/config.json'

end
