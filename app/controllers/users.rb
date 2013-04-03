#--
# Copyright(C) 2013 Giovanni Capuano <webmaster@giovannicapuano.net>
#
# This file is part of MyGameList.
#
# MyGameList is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# MyGameList is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with MyGameList.  If not, see <http://www.gnu.org/licenses/>.
#++

class MyGameList

  get '/user/login/?' do
    if logged_in?
      @output = Status::ALREADY_LOGGED
    end
    
    renderize :'user/login'
  end
  
  post '/user/login/?' do
    if logged_in?
      @output = Status::ALREADY_LOGGED
      return renderize :'user/login'
    end
      
    if user = User.authenticate(params[:username], params[:password])
      update = user.update(:secret => Perpetual::String::Miscs::random)
      set_cookie 'user', user.secret
      
      @output = update ? Status::SUCCESS : Status::FAIL
      return renderize :'user/login'
    end
    
    @output = Status::FAIL
    return renderize :'user/login'
  end
	
  # ---  
  get '/user/logout/?' do
    delete_cookie('user')
    redirect '/user/login'
  end
  
  # ---
  get '/user/signup/?' do
    if logged_in?
      @output = Status::ALREADY_LOGGED
    end
    
    renderize :'user/signup'
  end
  
  post '/user/signup/?' do
    if logged_in?
      @output = Status::ALREADY_LOGGED
      return renderize :'user/signup'
    end    
    
    inputs = {
      :username               =>  params[:username],
      :email                  =>  params[:email],
      :presentation           =>  params[:presentation],
      :password               =>  params[:password],
      :password_confirmation  =>  params[:password_confirmation]
    }
    
    user = User.new(inputs)
    
    if user.save
      set_cookie 'user', user.id
      
      @output = Status::SUCCESS
      return renderize :'user/signup'
    end
    
    @output = { :status => Status::FAIL, :error => user.errors }
    return renderize :'user/signup'
  end
  
  # ---
  get '/user/:username/edit/?' do
    unless logged_in?
      @output = Status::NOT_LOGGED
      return renderize :'user/edit'
    end
    
    unless current_user.username == params[:username]
      @output = Status::FORBIDDEN
      return renderize :'user/edit'
    end
    
    @user = current_user
    return renderize :'user/edit'
  end
  
  post '/user/:username/edit/?' do
    unless logged_in? || current_user.username == params[:username]
      @output = Status::NOT_LOGGED
      return renderize :'user/edit'
    end
    
    inputs = {
      :username               =>  params[:username],
      :email                  =>  params[:email],
      :presentation           =>  params[:presentation],
      :password               =>  params[:password],
      :password_confirmation  =>  params[:password_confirmation]
    }
    
    if inputs[:password].empty? || inputs[:password] != inputs[:password_confirmation]
      inputs.delete(:password)
      inputs.delete(:password_confirmation)
    end
    
    inputs.delete(:email) if inputs[:email].empty?
    
    @output = User.first(:username => params[:username]).update(inputs) ? Status::SUCCESS : Status::FAIL
    return renderize :'user/edit'
  end
  
  # ---
  get '/user/password_lost/?' do
    if logged_in?
      @output = Status::ALREADY_LOGGED
      return renderize :'user/password_lost'
    end
    
    return renderize :'user/password_lost'
  end
  
  get '/user/password_lost/:username/:code' do
    if logged_in?
      @output = Status::ALREADY_LOGGED
      return renderize :'user/password_lost'
    end
    
    inputs = {
      :username =>  params[:username],
      :code     =>  params[:code]
    }
    
    if inputs[:username].empty? || inputs[:code].empty?
      @output = Status::EMPTY_REQUIRED_FIELD
      return renderize :'user/password_lost'
    end
    
    @user = User.first(:username => params[:username], :lost_password => params[:code])
    body  = erb 'mail/password_recovered.erb'
    
    @output = User.password_recover(@user) ? Status::SUCCESS : Status::FAIL
    if @output == Status::SUCCESS
      @output = Pony.mail(
        :to         => @user.email,
        :from       => @admin_email,
        :subject    => 'New password for MyGameList',
        :html_body  => body
      ) ? Status::SUCCESS : Status::FAIL
    end
    
    return renderize :'user/password_lost'
  end
  
  post '/user/password_lost/?' do
    if logged_in?
      @output = Status::ALREADY_LOGGED
      return renderize :'user/password_lost'
    end
    
    inputs = {
      :username =>  params[:username],
      :email    =>  params[:email]
    }
    
    if inputs[:username].empty? || inputs[:email].empty?
      @output = Status::EMPTY_REQUIRED_FIELD
      return renderize :'user/password_lost'
    end
    
    @user   = User.first(:username => inputs[:username], :email => inputs[:email])
    @output = User.password_lost(@user) ? Status::SUCCESS : Status::FAIL
    if @output == Status::SUCCESS
      @output = Pony.mail(
        :to         => @user.email,
        :from       => @admin_email,
        :subject    => 'Password lost in MyGameList',
        :html_body  => erb('mail/password_lost.erb')
      ) ? Status::SUCCESS : Status::FAIL
    end
    
    return renderize :'user/password_lost'
  end
  
end
