require 'rho/rhocontroller'
require 'helpers/browser_helper'

class CarController < Rho::RhoController
  include BrowserHelper

  #GET /Car
  def index
    @cars = Car.find(:all)
    Rho::NativeTabbar.remove
    WebView.navigate("/app/Car/new") if @cars.empty?
    render :back => '/app' unless @cars.empty?
  end

  # GET /Car/{1}
  def show
    @car = Car.find(@params['id'])
    if @car
      render :action => :show
    else
      redirect :action => :index
    end
  end

  # GET /Car/new
  def new
    @car = Car.new
    render :action => :new
  end

  # GET /Car/{1}/edit
  def edit
    @car = Car.find(@params['id'])
    if @car
      render :action => :edit
    else
      redirect :action => :index
    end
  end

  # POST /Car/create
  def create
    begin
      params = Car.accept_params(@params['car'])
      Car.create params
      redirect :action => :index
    rescue ArgumentError => msg
      error_popup msg
    end
  end

  # POST /Car/{1}/update
  def update
    begin
      params = Car.accept_params(@params['car'])
      @car = Car.find(@params['id'])
      @car.update_attributes(@params['car']) if @car
      redirect(:controller => :Fuel, :action => :index)
    rescue ArgumentError => msg
      error_popup msg
    end
  end
  
  def error_popup(msg)
    Alert.show_popup(
        :message=>"#{msg}\n",
        :title=>"Error",
        :icon => :alert,
        :buttons => ["Ok"],
        :callback => url_for(:action => error_callback)
    )
  end
   
  def error_callback
    redirect :action => :index
  end

  
  # POST /Car/{1}/delete
  def delete
    @car = Car.find(@params['id'])
    @car.destroy if @car
    redirect :action => :index  end
end
