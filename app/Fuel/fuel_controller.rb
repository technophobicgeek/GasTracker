require 'rho/rhocontroller'
require 'helpers/browser_helper'

class FuelController < Rho::RhoController
  include BrowserHelper
    
  def log(msg)
    $rholog.info("APP",msg)
  end

  #GET /Fuel: render all fillups for given car
  def index
    $car_id = @params['car_id'] unless @params['car_id'].nil?
    @fuels = fuels_finder
    WebView.navigate("/app/Fuel/new")  if @fuels.empty?
    render :back => '/app' unless @fuels.empty?
  end

  def fuels_finder
    Fuel.find(
      :all,
      :conditions => {'car_id' => $car_id},
      :order => 'timestamp',
      :orderdir => 'DESC'
    )
  end
  
  # GET /Fuel/new
  def new
    @fuel = Fuel.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Fuel/{1}/edit
  def edit
    @fuel = Fuel.find(@params['id'])
    if @fuel
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Fuel/create
  def create
    create_or_update do |params|
      @fuel = Fuel.create params
      Alert.show_popup(
          :message=>"Time to reset your trip odometer!\n",
          :title=>"Reminder",
          :icon => :info,
          :buttons => ["Ok"]
      ) if @fuel
    end
  end

  # POST /Fuel/{1}/update
  def update
    create_or_update do |params|
      @fuel = Fuel.find(@params['id'])
      @fuel.update_attributes params if @fuel
    end
  end
  
  def create_or_update
    begin
      params = Fuel.accept_params(@params['fuel'])
      yield(params) if params
      redirect :action => :index
    rescue ArgumentError => msg
      Alert.show_popup(
          :message=>"#{msg}\n",
          :title=>"Error",
          :icon => :alert,
          :buttons => ["Ok"],
          :callback => url_for(:action => error_callback)
      )
    end
  end
  
  def error_callback
    WebView.navigate WebView.current_location
  end

  # POST /Fuel/{1}/delete
  def delete
    @fuel = Fuel.find(@params['id'])
    @fuel.destroy if @fuel
    redirect :action => :index
  end

  def chart
    stats_helper
    @values = []
    @xticks = (1..@fuels.length).to_a
    @yticks = ((@minimum/5).floor .. (@maximum/5).ceil).map{|x| x*5}
    @fuels.each_with_index do |fuel,i|
      @values << [i+1,fuel.mileage.to_f]
    end
    render :action => :chart, :back => url_for(:action => :index)
  end
  
  def stats
    stats_helper
    render :action => :stats, :back => url_for(:action => :index)
  end
  
  def stats_helper
    @carname = Car.find($car_id).name
    @fuels = fuels_finder
    mileages = @fuels.map{|f| f.mileage.to_f}
    @maximum = mileages.max
    @minimum = mileages.min
    @average = mileages.inject(0.0){ |sum, el| sum + el }.to_f / mileages.size
  end
end
