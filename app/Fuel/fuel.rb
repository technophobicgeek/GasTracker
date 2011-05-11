# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Fuel
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Fuel.
  # enable :sync

  #add model specifc code here
  
  #Validations
  #
  def self.accept_params(params)
    if params
      check_value(params["distance"],"Distance") 
      check_value(params["unit_price"],"Price") 
      check_value(params["volume"],"Volume") 
      mileage = sprintf("%.1f",params["distance"].to_f / params["volume"].to_f).to_f
      params[:mileage] = mileage
      params[:timestamp] = Time.now.to_i
    end
    return params
  end
  
  def self.check_value(param,name)
    begin
      raise RangeError if Float(param) <= 0
    rescue ArgumentError
      raise ArgumentError, "#{name} must be a number greater than Zero"
    rescue RangeError
      raise ArgumentError, "#{name} must be greater than Zero"
    end
  end
  
  def fill_date
    Time.at(self.timestamp).strftime("%m/%d") if self.timestamp
    "" unless self.timestamp
  end
end
