# app.rb

require 'sinatra'
require 'sinatra/activerecord'
require './environments'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'omniauth-twitter'

use OmniAuth::Builder do
  provider :twitter, 'C5fNcJabyRF43KLOPit2bVH6D', 'Ugi5aNjf7ajzFP4XEbBydd8LiPWVFg8WjDEKAKhlkwaFMfu4bA'
end

enable :sessions


class Post < ActiveRecord::Base
 validates :title, presence: true, length: { minimum: 5 }
 validates :body, presence: true
end

get "/" do
  @title = "Welcome."
  erb :"/index"
end
get "/blogs" do
  @posts = Post.order("created_at DESC")
  @title = "Welcome."
  erb :"posts/blogs"
end

helpers do
  def title
    if @title
      "#{@title}"
    else
      "Welcome."
    end
  end
end

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end


get "/posts/manage" do
 redirect to("/auth/twitter")
end

get "/posts/create" do
 @title = "Create post"
 @post = Post.new
 erb :"posts/create"
end

post "/posts" do
 @post = Post.new(params[:post])
 if @post.save
   redirect "posts/#{@post.id}", :notice => 'The blog has been successfully posted. (This message will disapear in 4 seconds.)'
 else
   redirect "posts/create", :error => 'Something has gone wrong. Try again. (This message will disapear in 4 seconds.)'
 end
end

get "/posts/:id" do
 @post = Post.find(params[:id])
 @title = @post.title
 erb :"posts/adminview"
end

# edit post
get "/posts/:id/edit" do
  @post = Post.find(params[:id])
  @title = "Edit Form"
  erb :"posts/edit"
end
put "/posts/:id" do
  @post = Post.find(params[:id])
  @post.update(params[:post])
  redirect "/posts/#{@post.id}"
end
#delete post

get '/posts/:id/delete' do
  @post = Post.find(params[:id])
  @post.delete
  redirect "/blogs"
end

get "/manage" do
  erb :manage
end

get '/experience' do
  erb :experience
end
get '/education' do
  erb :education
end
get '/contact_me' do
  erb :contact_me
end


configure do
  enable :sessions
end

helpers do
  def admin?
    session[:admin]
  end
end

get '/login' do
  redirect to("/auth/twitter")
end

get '/logout' do
  session[:admin] = nil
  "You are now logged out"
end

get '/auth/twitter/callback' do
  env['omniauth.auth'] ? session[:admin] = true : halt(401,'Not Authorized')
   @title = "Create post"
   @post = Post.new
   erb :"posts/manage"
end
get '/auth/failure' do
  params[:message]
end



