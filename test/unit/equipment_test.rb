require File.dirname(__FILE__) + '/../test_helper'

class EquipmentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  context "ActiveRecord" do
    setup do
      Factory(:equipment)
    end
    
    context "validations" do
      should validate_presence_of :serial
    end

    context "relations" do
      should belong_to :boat
      should belong_to :equipment_type
    end
  end
  
  context "For two boats" do
    setup do
      @boat1 = UseCaseSamples.build_boat
      @boat2 = UseCaseSamples.build_boat
    end
    
    should "equipment_types of boat1 must be opposite of equipment_types of boat2" do
      types1 = @boat1.equipment.*.equipment_type
      types2 = @boat2.equipment.*.equipment_type
      
      {types1 => types2, types2 => types1}.each do |types_a, types_b|
        for type_a in types_a
          for type_b in types_b
            assert_equal false, type_a == type_b
          end
        end
      end
    end
  end
end
