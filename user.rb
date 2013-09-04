class User
  attr_reader :name

  def initialize socket
    @name = $generator.name(:all)
    @socket = socket
  end

  def message msg
    @socket.send msg
  end
end

class NoUser
  def name
    "Nobody"
  end
end
