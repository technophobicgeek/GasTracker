require 'rho/rhocontroller'
require 'helpers/browser_helper'

class CarController < Rho::RhoController
  include BrowserHelper

  #GET /Car
  def index
    @cars = Car.find(:all)
    WebView.navigate("/app/Car/new") if @cars.empty?
    render :back => '/app' unless @cars.empty?
  end

  # GET /Car/{1}
  def show
    @car = Car.find(@params['id'])
    if @car
      render :action => :show, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # GET /Car/new
  def new
    @car = Car.new
    render :action => :new, :back => url_for(:action => :index)
  end

  # GET /Car/{1}/edit
  def edit
    @car = Car.find(@params['id'])
    if @car
      render :action => :edit, :back => url_for(:controller => :Fuel, :action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Car/create
  def create
    create_or_update do |params|
      Car.create params
    end
  end

  # POST /Car/{1}/update
  def update
    create_or_update do |params|
      @car = Car.find(@params['id'])
      @car.update_attributes(@params['car']) if @car
    end
  end
  
  def create_or_update
    begin
      params = Car.accept_params(@params['car'])
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
    redirect :action => :index
  end

  
  # POST /Car/{1}/delete
  def delete
    @car = Car.find(@params['id'])
    @car.destroy if @car
    redirect :action => :index  end
end
