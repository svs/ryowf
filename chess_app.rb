require 'chess'
require 'data_mapper'
require 'rack'
require 'rack/contrib'
require_relative './poof/router.rb'
require_relative './poof/controller_action.rb'
require 'awesome_print'
require_relative './models.rb'

DataMapper.setup(:default, 'sqlite::memory:')
DataMapper.auto_migrate!
DataMapper.finalize


class ChessApp
  def call(env)
    env.update('POST_DATA' => Rack::Utils.parse_nested_query(env['rack.input'].read))
    env['rack.input'].rewind
    Router.new(env).call
  end
end


module GamesController

  class Index < ControllerAction

    def get
      [200, {}, Game.all.to_json]
    end

  end

  class Create < ControllerAction

    def post
      @game = Game.create(params[:game])
      [200, {}, @game.to_json]
    end

  end

  class Update < ControllerAction

    def put
      @game = Game.get(params[:id])
      @game.update(params["game"])
      @game.valid? ? [200,{}, @game.attributes] : [422,{},@game.errors]
    end
  end

end
