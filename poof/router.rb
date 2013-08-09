require 'active_support/core_ext/string/inflections'

class Router

  attr_reader :env
  attr_accessor :route

  def initialize(env)
    ap env
    @env = env
  end

  def call
    handler.new(self).send(method)
  end

  def params
    ActiveSupport::HashWithIndifferentAccess.new(route.except(:action, :controller).merge(post_data))
  end

  private

  def route
    $routes.recognize_path(env['PATH_INFO'], {:method => method.upcase})
  end


  def handler
    controller.module_eval(action)
  end


  def controller
    "#{route[:controller]}Controller".camelize.constantize
  end

  def action
    route[:action].camelize
  end

  def method
    env['REQUEST_METHOD'].downcase
  end

  def post_data
    env['POST_DATA'] || {}
  end

end
