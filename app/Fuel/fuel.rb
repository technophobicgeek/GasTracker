# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Fuel
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Fuel.
  # enable :sync

  #add model specifc code here
  
  #Validations
  #
  #def self.accept_params(params)
  #  distance = params[:distance].to_f
  #  return [false,"Distance must be a number greater than Zero"] unless distance > 0
  #  unit_price = params[:unit_price].to_f
  #  return [false,"Price must be a number greater than Zero"] unless unit_price > 0
  #  volume = params[:volume].to_f
  #  return [false,"Volume must be a number greater than Zero"] unless volume > 0
  #  mileage = sprintf("%.1f",@fuel.distance.to_f / @fuel.volume.to_f).to_f
  #  params[:mileage] = mileage
  #  return params
  #end
end
