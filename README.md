##devise-cancancan-rolify-rails_admin
##devise
#####Gemfile 加入
```
gem 'devise'
```
`bundle`
#####初始化 devise

	rails g devise:install
####devise 環境
>config/environments/development.rb

```
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
```

####消息功能

>app/views/layouts/application.html.erb

	<p class="notice"><%= notice %></p>  
	<p class="alert"><%= alert %></p> 

####登入登出
```
<% if current_user %>
  <%= link_to('退出', destroy_user_session_path, :method => :delete) %> |
  <%= link_to('修改密码', edit_registration_path(:user)) %>
<% else %>
  <%= link_to('注册', new_registration_path(:user)) %> |
  <%= link_to('登录', new_session_path(:user)) %>
<% end %><span></span>
```
####產生 user
```
rails g devise User
rake db:migrate
```
#### 權限
`before_filter :authenticate_user! , except: [:index]`
##cancanca-rolefy
####Gemfile
```
gem 'cancan'
gem 'rolify'
```
`bundle`
####產生 Role
```
rails g rolify Role User
```
####產生cancan Ability
```
rails g cancan:ability
```
`rake db:migrate`
####註冊時，分配 Rolify 身分
>ApplicationController.rb

```
def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      if User.count == 1
        resource.add_role 'admin'
      end
      resource
    end
    root_path
  end
```
#### cancan 權限管理
>app/models/ability.rb

```
class Ability
  include CanCan::Ability

  def initialize(user)
    if user.blank?
      # not logged in
      cannot :manage, :all
      basic_read_only
    elsif user.has_role?(:admin)
    # admin
    can :manage, :all
    else # manager
    can :read, Post
    end
  end

  protected

  def basic_read_only
    can :read,    Post
  end
end
```
>:manage: 是指這個 controller 內所有的 action
>:read : 指 :index 和 :show
>:update: 指 :edit 和 :update
>:destroy: 指 :destroy
>:create: 指 :new 和 :crate

####Controller中加入權限控管
```
class PostsController < ApplicationController
	authorize_resource #這行

	def index
	  ....
	end
```
####view
```
<% if user_signed_in? %>
    <p>The user is loged in.</p>
    <% if can? :update, @post %>
        <p>You can update.</p>
    <% else %>
        <p>You can not update</p>
    <% end %>

<% end %>
```
####權限不足提示
>app/controllers/application_controller.rb

```
rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
```

##rails_admin
####Gemfile
	gem 'rails_admin', '~> 0.6.7'

####產生 rails_admin
```
rails g rails_admin:install
rake db:migrate
```
####修改config
>config/initializers/rails_admin.rb

```
  ## == Devise ==
   config.authenticate_with do
     warden.authenticate! scope: :user
   end
   config.current_user_method(&:current_user)

  ## == Cancan ==
   config.authorize_with :cancan
```
####修改提示
>app/controllers/application_controller.rb

```
rescue_from CanCan::AccessDenied do |exception|
  redirect_to main_app.root_url, :alert => exception.message
end
```

##限制只能管理自己的 post

####增加關聯
```
rails g migration add_user_id_to_post user_id:integer
rake db:migrate
```

>app/models/user.rb

####has_many 
```
class User < ActiveRecord::Base
...
...
  has_many :posts
end
```
####belongs_to 
```
class Post < ActiveRecord::Base
...
...
  belongs_to :author, class_name: "User", foreign_key: :user_id

  def editable_by?(user)
    user && user == author
  end
end
```
####belongs_to
```
class Post < ActiveRecord::Base
	belongs_to :user
end
```
####controller
```
  def new
    @post = current_user.posts.build
    respond_with(@post)
  end

  def edit
    authorize! :update,@post
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      respond_with(@post)
    else
      render 'new'
    end
  end
```
####修改 cancan
```
   can :create,Post
   can :update, Post do |post|
        (post.user_id == user.id)
   end

   can :destroy, Post do |post|
        (post.user_id == user.id)
   end
```

####參考
>http://deveede.logdown.com/posts/206943-use-deviserolify-cancan-control-permissions
>https://github.com/robertzhang/rails-devise-cancancan-rolify
>http://blog.xdite.net/posts/2012/07/30/cancan-rule-engine-authorization-based-library-3/


