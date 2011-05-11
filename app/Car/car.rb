class Car
  include Rhom::PropertyBag

  def self.accept_params(params)
    if params
      name = params["name"]
      if name.nil? || name == "" || name.length==0
        raise ArgumentError, "Name of car cannot be empty!"
      end
    end
    return params
  end
end
