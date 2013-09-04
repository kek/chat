class Chat
  def initialize
    @users = []
  end

  def add_user user
    @users << user
  end

  def broadcast msg
    @users.each do |user|
      user.message msg
    end
  end
end
