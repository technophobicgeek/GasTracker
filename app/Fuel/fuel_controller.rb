require 'rho/rhocontroller'
require 'rho/rhotabbar'
require 'helpers/browser_helper'

class FuelController < Rho::RhoController
  include BrowserHelper
    
  def log(msg)
    $rholog.info("APP",msg)
  end
  
  
  def set_tabbar_index    
    tabbar = [
      {
        :label => 'Fillups',
        :action => url_for(:action => :fillups),
        :icon => '/public/images/android/table.png',
        :reload => true
      },
      {
        :label => 'Home',
        :action => url_for(:controller => :Car,:action => :index),
        :icon => '/public/images/android/house.png',
      },
      {
        :label => 'Edit Car',
        :action => url_for(:controller => :Car, :action => :edit, :query => {:id => $car_id}),
        :icon => '/public/images/android/car.png',
      },
      {
        :label => 'Chart',
        :action => url_for(:action => :summary),
        :icon => '/public/images/android/chart_line.png',
      },
      {
        :label => 'Add Entry',
        :action => url_for(:action => :new),
        :icon => '/public/images/android/add.png',
        :reload => true
      }
    ]
    Rho::NativeTabbar.create(tabbar)
    $tabbar_index_active = true
  end
 

  #GET /Fuel: render  fillups for given car
  def fillups
    @last_page = ($car.fillup_count.to_i - 1) / $fillups_per_page.to_i
    @fuels = Fuel.paginate(
              {
                :conditions => {'car_id' => $car_id},
                :order => 'timestamp',
                :orderdir => 'DESC',
                :per_page => $fillups_per_page,
                :page => $fillups_page,
                :select => ['timestamp','distance','volume','mileage','fill_date']
              }
            )
    if (@fuels.empty? and $fillups_page == 0)
      WebView.navigate("/app/Fuel/new")
    else
      render
    end
  end
 
  def older_fillups
    $fillups_page += 1
    redirect :action => :fillups
  end

  def newer_fillups
    $fillups_page -= 1
    redirect :action => :fillups
  end
  
  def index
    Rho::NativeTabbar.remove
    $car_id = @params['car_id'] unless @params['car_id'].nil?
    $car = Car.find($car_id) if $car_id
    $fillups_page = (@params['page'].nil? ? 0 : @params['page'].to_i)
    $fillups_per_page = 5
    set_tabbar_index 
  end
  
  
  # GET /Fuel/new
  def new
    @fuel = Fuel.new
    render :action => :new
  end

  # GET /Fuel/{1}/edit
  def edit
    @fuel = Fuel.find(@params['id'])
    if @fuel
      render :action => :edit
    else
      redirect :action => :fillups
    end
  end

  # POST /Fuel/create
  def create
    create_or_update do |params|
      @fuel = Fuel.create params
      $car.fillup_count = ($car.fillup_count.to_i)+1
      $car.save
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
      redirect :action => :fillups
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
    $car.fillup_count = ($car.fillup_count.to_i)-1
    $car.save
    redirect :action => :fillups
  end

  def set_tabbar_stats
    tabbar = [
      {
        :label => 'Chart',
        :action => url_for(:action => :chart),
        :icon => '/public/images/android/chart_line.png',
        #:web_bkg_color => "#dddddd",
        :reload => true
      },
      {
        :label => 'Stats',
        :action => url_for(:action => :stats) ,
        :icon => '/public/images/android/sum.png',
        #:web_bkg_color => "#dddddd"
      },
      {
        :label => 'Fillups',
        :action => url_for(:action => :index),
        :icon => '/public/images/android/table.png',
        #:web_bkg_color => "#dddddd"
      },
      {
        :label => 'Home',
        :action => url_for(:controller => :Car,:action => :index),
        :icon => '/public/images/android/house.png',
        #:web_bkg_color => "#dddddd"
      },
    ]
    Rho::NativeTabbar.create(tabbar)
    $tabbar_stats_active = true
  end
  
  def summary
    Rho::NativeTabbar.remove
    set_tabbar_stats
  end
  
  def chart
    stats_helper
    @values = []
    @xticks = @fuels.map{|f| f.fill_date}
    @yticks = ((@minimum/5).floor .. (@maximum/5).ceil).map{|x| x*5}
    @fuels.each_with_index do |fuel,i|
      @values << [i+1,fuel.mileage.to_f]
    end
    render :action => :chart
  end
  
  def stats
    stats_helper
    render :action => :stats
  end
  
  def stats_helper
    @carname = $car.name
    @fuels = Fuel.find(
              :all,
              :conditions => {'car_id' => $car_id},
              :order => 'timestamp',
              :orderdir => 'DESC',
              :select => ["fill_date","mileage"]
            )[0..10]
    mileages = @fuels.map{|f| f.mileage.to_f}
    @maximum = mileages.max
    @minimum = mileages.min
    @average = sprintf("%.1f",mileages.inject(0.0){ |sum, el| sum + el }.to_f / mileages.size)
  end
end
