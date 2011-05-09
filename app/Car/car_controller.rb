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
      render :action => :edit, :back => url_for(:action => :index)
    else
      redirect :action => :index
    end
  end

  # POST /Car/create
  def create
    @car = Car.create(@params['car'])
    redirect :action => :index
  end

  # POST /Car/{1}/update
  def update
    @car = Car.find(@params['id'])
    @car.update_attributes(@params['car']) if @car
    redirect :action => :index
  end

  # POST /Car/{1}/delete
  def delete
    @car = Car.find(@params['id'])
    @car.destroy if @car
    redirect :action => :index  end
end
