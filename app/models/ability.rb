class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      # not logged in
      basic_read_only
    elsif user.has_role?(:admin)
    # admin
      can :manage, :all
    else
      can :read,Post
      can :create,Post
      can :update, Post do |post|
        (post.user_id == user.id)
      end

      can :destroy, Post do |post|
        (post.user_id == user.id)
      end

    end



  end

protected

  def basic_read_only
    can :read,Post
  end
end
