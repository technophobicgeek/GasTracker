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
    check_value(params["distance"],"Distance")
    check_value(params["unit_price"],"Price")
    check_value(params["volume"],"Volume")
    mileage = sprintf("%.1f",params["distance"].to_f / params["volume"].to_f).to_f
    params[:mileage] = mileage
    return params
  end
  
  def self.check_value(param,name)
    raise ArgumentError, "#{name} must be a number greater than Zero" unless param.to_f > 0
  end
end
