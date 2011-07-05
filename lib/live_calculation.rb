class LiveCalculation
  
  # Initializes the live calculation object with a given set of marks. The marks can be numbers, strings, or any
  # kind of object that is comparable using the '==' operator
  def initialize marks
    @marks = marks
    @marks_size = @marks.size
  end
  
  # Calculates the current position, even if some marks within the situation are missing
  def calculate situation
    result = primitive_calculation situation
    raise LiveCalculationException, "Could not calculate a valid result" if result < 0.0
    result
  end
  
  private
  
  # Performs a primitive calculation on a given situation, using a stepping algorithm
  def primitive_calculation situation
    # Set the counter to zero
    count = 0
    
    # For each element in the situation, scan the marks list from the count offset to the next hit
    for element in situation
      while @marks[count] != element
        count += 1
        
        # if we run out of space, there is an illegal element within the situation, return -1.0
        return -1.0 if @marks_size <= count
      end
      count += 1 # Need to step one time always
    end
    count.to_f / @marks_size.to_f
  end
  
end