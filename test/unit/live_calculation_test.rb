 require File.dirname(__FILE__) + '/../test_helper'
 
 class LiveCalculationTest < ActiveSupport::TestCase
   context "Simple Live Calculation" do
     subject { LiveCalculation.new [1,2,3,4,5] }
     
     should "return 1.0 when all positions are occuppied" do
       assert_equal 1.0, subject.calculate([1,2,3,4,5])
     end

     should "return 0.6 when the first, second and third position are occuppied" do
       assert_equal 0.6, subject.calculate([1,2,3])
     end
   
     should "return 0.6 when the first and third position are occuppied, and a gap exists" do
       assert_equal 0.6, subject.calculate([1,3])
     end
     
     should "fail whenever there are too many positions" do
       assert_raise(LiveCalculationException) { subject.calculate [1,2,3,4,5,6] }
     end
     
     should "fail whenever there are wrong positions" do
       assert_raise(LiveCalculationException) { subject.calculate [1,10] }
     end
   end

 
   context "Complex Live Calculation" do
     subject { LiveCalculation.new [1,2,2,1,3,4,0,9] }
     
     should "return 1.0 when all positions are occuppied" do
       assert_equal 1.0, subject.calculate([1,2,2,1,3,4,0,9])
     end
     
     should "return 0.5 when the first half positions are occuppied" do
       assert_equal 0.5, subject.calculate([1,2,2,1])
     end
     
     should "return 0.5 when the first half positions are occuppied, with gaps" do
       assert_equal 0.5, subject.calculate([1,1])
     end

     should "return 1.0 when only the last position is known" do
       assert_equal 1.0, subject.calculate([9])
     end
     
     should "return 0.0 when no position is known" do
       assert_equal 0.0, subject.calculate([])
     end
   end

 
   context "Complex Live Calculation with foreign objects" do
     subject { LiveCalculation.new ["start", 0, 1, "finish"] }
     
     should "return 1.0 when all positions are occuppied" do
       assert_equal 1.0, subject.calculate(["start", 0, 1, "finish"])
     end
     
     should "return 1.0 when only the last position is known" do
       assert_equal 1.0, subject.calculate(["finish"])
     end
     
     should "return 0.0 when no position is known" do
       assert_equal 0.0, subject.calculate([])
     end
     
     should "return 0.5 when the second position is known" do
       assert_equal 0.5, subject.calculate([0])
     end
   end
 end
 
