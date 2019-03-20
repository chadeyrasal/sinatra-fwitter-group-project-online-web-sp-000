require './config/environment'
require 'sinatra/base'
require 'rack-flash'


class ApplicationController < Sinatra::Base

  enable :sessions
  use Rack::Flash

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    if Helpers.is_logged_in?(session)
      redirect "/tweets"
    end

    erb :signup
  end

  post "/signup" do
    params.each do |label, user_input|
      if user_input.empty?
        flash[:signup_error] = "Please enter a value for #{label}"
        redirect "/signup"
      end
    end

    user = User.create(:username => params[:username], :email => params[:email], :password => params[:password])
    session[:user_id] = user.id

    redirect "/tweets"
  end

  get "/login" do
    erb :login
  end

  post "/login" do
    user = User.find_by(:username => params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/tweets"
    else
      redirect "/login"
    end
  end

  get "/tweets" do
    @user = Helpers.current_user(session)
    @tweets = Tweet.all
    erb :"tweets/index"
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

end
