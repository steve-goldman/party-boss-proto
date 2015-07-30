module ClassRecord

  # Requires the class mixing this in defines a constant `Members',
  # which is an array of hashes with member `name' and `type'.
  #
  # Provides an initializer that takes the members in order and an
  # accessor for each member
  
  def initialize(*members)
    throw "expected arguments: #{self.members.count}" if members.count != self.class::Members.count

    @_members = {}
    i = 0
    self.class::Members.each_index do |index|
      member = self.class::Members[index]
      @_members[member[:name]] = members[index]
      # define the accessor for this member (but only once)
      if !self.class.instance_methods(false).include?(member[:name])
        self.class.send(:define_method, member[:name]) do
          @_members[member[:name]]
        end
        if !member[:is_array]
          self.class.send(:define_method, "#{member[:name]}=") do |newValue|
            @_members[member[:name]] = newValue
          end
        end
      end
      i += 1
    end
  end

end
