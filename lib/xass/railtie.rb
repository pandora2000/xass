module Xass
  class Railtie < Rails::Railtie
    initializer "xass.view_helpers" do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end
