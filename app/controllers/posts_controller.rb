class PostsController < ApplicationController
  #GET "/posts"
  def index
    @posts = Post.where(published: true)
    render json: @posts, status: :ok
  end
  def create
  end
  def show
    @post = Post.find(params[:id])
    render json: @post, status: :ok
  end
end