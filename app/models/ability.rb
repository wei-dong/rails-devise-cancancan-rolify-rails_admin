class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      # not logged in
      basic_read_only
      can :access, :rails_admin
    elsif user.has_role?(:admin)
    # admin
      can :manage, :all
    else
      can :read,Post

    end



  end

protected

  def basic_read_only
    can :read,Post
  end
end
