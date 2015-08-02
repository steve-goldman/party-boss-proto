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
      if !self.class.instance_methods(false).include?(member[:name].to_sym)
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

    # define equals methods
    self.class.send(:define_method, :elem_equals?) do |type, elem, other_elem|
      if type.superclass == BaseObject
        return false if !elem.equals?(other_elem)
      else
        return false if elem != other_elem
      end
      true
    end
    
    self.class.send(:define_method, :equals?) do |other|
      return false if !other.is_a? self.class
      self.class::Members.each do |member|
        value = send(member[:name])
        otherValue = other.send(member[:name])
        if (value.nil? || otherValue.nil?) && member[:can_be_nil]
          return value.nil? && otherValue.nil?
        elsif member[:is_array]
          if value.count != otherValue.count
            return false
          end
          if member[:unordered]
            value.count.times do |index|
              if !otherValue.reduce(false) { |found, elem|
                   found || elem_equals?(member[:type], value[index], elem) }
                return false
              end
            end
          else
            value.count.times do |index|
              if !elem_equals?(member[:type], value[index], otherValue[index])
                return false
              end
            end
          end
        else
          if !elem_equals?(member[:type], value, otherValue)
            return false
          end
        end
      end
      true
    end

    after_init
  end

end
