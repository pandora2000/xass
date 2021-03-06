require 'bundler/setup'
Bundler.require

require 'xass'
require 'action_view/railtie'
require 'nokogiri'

ActionView::Helpers.include(Xass::ViewHelpers)

class View
  def initialize
    @action_view = ActionView::Base.new [File.expand_path('../problems', __FILE__)]
  end

  def render(path)
    @action_view.render(file: path)
  end
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
