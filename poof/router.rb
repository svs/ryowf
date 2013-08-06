require 'active_support/core_ext/string/inflections'

class Router

  attr_reader :env

  def initialize(env)
#    ap env
    @env = env
  end

  def params
    (id ? {:id => id} : {}).merge(env['POST_DATA'] || {})
  end

  def call
    handler.new(self).send(method)
  end


  private

  def handler
    controller.module_eval(action)
  end

  def path_array
    env['PATH_INFO'].split('/')
  end

  def id
    path_array.map(&:to_i).select{|x| x > 0 }[0]
  end

  def controller
    "#{path_array[1]}Controller".camelize.constantize
  end

  def action
    return "index".camelize if get?
    return "create".camelize if post?
    return "update".camelize if put?
  end

  def method
    env['REQUEST_METHOD'].downcase
  end

  def get?
    method.downcase == "get"
  end

  def post?
    method.downcase == "post"
  end

  def put?
    method.downcase == "put"
  end
end
