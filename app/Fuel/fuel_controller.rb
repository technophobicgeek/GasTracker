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
    @fuels = Fuel.find(:all, :conditions => {'car_id' => $car_id})
    WebView.navigate("/app/Fuel/new")  if @fuels.empty?
    render :back => '/app' unless @fuels.empty?
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
    create_or_update(:new) do |params|
      Fuel.create params
    end
  end

  # POST /Fuel/{1}/update
  def update
    create_or_update(:edit) do |params|
      @fuel = Fuel.find(@params['id'])
      @fuel.update_attributes params if @fuel
    end
  end
  
  def create_or_update(origin)
    begin
      yield(Fuel.accept_params(@params['fuel']))
      redirect :action => :index
    rescue ArgumentError => msg
      Alert.show_popup(
          :message=>"#{msg}\n",
          :title=>"Error",
          :icon => :alert,
          :buttons => ["Ok"],
          :callback => url_for(:action => popup_callback)
      )
    end
  end
  
  def popup_callback
    WebView.navigate WebView.current_location
  end

  # POST /Fuel/{1}/delete
  def delete
    @fuel = Fuel.find(@params['id'])
    @fuel.destroy if @fuel
    redirect :action => :index
  end

  def chart
    @fuels = Fuel.find(:all, :conditions => {'car_id' => $car_id})
    maxm = (@fuels.map{|f| f.mileage.to_f}).max
    @values = []
    @xticks = (1..@fuels.length).to_a
    @yticks = (0..(maxm < 50 ? 10:20)).map{|x| x*5}
    @fuels.each_with_index do |fuel,i|
      @values << [i+1,fuel.mileage.to_f]
    end
    render :action => :chart, :back => url_for(:action => :index)
  end
  
end
