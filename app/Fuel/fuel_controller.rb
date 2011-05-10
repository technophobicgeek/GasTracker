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
    render :action => :edit, :back => url_for(:action => :index) if @fuel
    redirect :action => :index unless @fuel
    end
  end

  # POST /Fuel/create
  def create
    @fuel = Fuel.create(@params['fuel'])
    if @fuel
      mileage = sprintf("%.1f",@fuel.distance.to_f / @fuel.volume.to_f)
      @fuel.update_attributes({:mileage => mileage})
    end
    redirect :action => :index
  end

  # POST /Fuel/{1}/update
  def update
    @fuel = Fuel.find(@params['id'])
    @fuel.update_attributes(@params['fuel']) if @fuel
    redirect :action => :index
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
