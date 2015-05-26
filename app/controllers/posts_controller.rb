class PostsController < ApplicationController
  before_action :find_post, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user! , except: [:index]
  authorize_resource

  respond_to :html

  def index
    @posts = Post.all
    respond_with(@posts)
  end

  def show
    respond_with(@post)
  end

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

  def update
    if @post.update(post_params)
      respond_with(@post)
    else
      render 'edit'
    end
  end

  def destroy
    @post.destroy
    respond_with(@post)

  end

  private
    def find_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:title, :content)
    end
end
