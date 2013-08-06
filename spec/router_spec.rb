require 'rspec'
require_relative '../chess_app.rb'
require 'pry_debug'
require 'json'

DataMapper.setup(:default, 'sqlite::memory:')
DataMapper.auto_migrate!

RSpec::Matchers.define :route_to do |expected|
  match do |actual|
    actual.send(:controller).to_s == expected.to_s.split("::")[0] &&
    actual.send(:action).to_s == expected.to_s.split("::")[1] &&
      (@params ? (actual.send(:params) == @params) : true)

  end

  chain :with do |params|
    @params = params
  end
end


describe "routing" do

  specify { Router.new(Rack::MockRequest.env_for('/games', {'REQUEST_METHOD' => 'get'})).should route_to(GamesController::Index) }
  specify { Router.new(Rack::MockRequest.env_for('/games', {'REQUEST_METHOD' => 'post'})).should route_to(GamesController::Create) }
  specify { Router.new(Rack::MockRequest.env_for('/games/2/', {'REQUEST_METHOD' => 'put'})).should route_to(GamesController::Update).with(:id => 2) }
end


describe "games controller" do

  before(:all) { Game.destroy! }

  context "index" do
    specify {
      Game.create
      @r = Rack::MockRequest.new(ChessApp.new).get('/games')
      JSON.load(@r.body).should be_an Array
      JSON.load(@r.body).count.should == 1
    }
  end


  context "post" do
    specify {
      expect { Rack::MockRequest.new(ChessApp.new).post('/games') }.to change(Game, :count).by(1)
    }
  end

  context "put" do

    specify {
      @g = Game.create
      Game.any_instance.should_receive(:'add_move=').with("d4")
      Rack::MockRequest.new(ChessApp.new).put("/games/#{@g.id}", :params => {:game => { :add_move => "d4"}})
    }

    specify {
      @g = Game.create
      @r = Rack::MockRequest.new(ChessApp.new).put("/games/#{@g.id}", :params => {:game => { :add_move => "a4"}})
      @r.should be_ok
    }
  end


end
