class ControllerAction

  def initialize(data)
    @data = data
  end

  def params
    data.params
  end

  private

  attr_reader :data

end
