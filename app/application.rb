require 'rho/rhoapplication'

class AppApplication < Rho::RhoApplication
  def initialize

    @tabs = nil
    @@tabbar = nil
    
    @@toolbar = [
      {:action => :back},
      {:action => :separator},
      {:action => :home},
      #{:action => :separator},
      #{:action => :options}
    ]
    
    super
    $rholog = RhoLog.new

    $screen_width = System.get_property('screen_width')
    $screen_height = System.get_property('screen_height')

  end
end
