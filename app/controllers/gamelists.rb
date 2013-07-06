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
  
  get '/gamelist/:username/new/?' do
    unless logged_in?
      @output = Status::NOT_LOGGED
      return renderize :'gamelist/new'
    end
    
    unless current_user.username == params[:username]
      @output = Status::FORBIDDEN
      return renderize :'gamelist/new'
    end
    
    return renderize :'gamelist/new'
  end
  
  post '/gamelist/:username/new/?' do
    unless logged_in?
      @output = Status::NOT_LOGGED
      return renderize :'gamelist/new'
    end
    
    unless current_user.username == params[:username]
      @output = Status::FORBIDDEN
      return renderize :'gamelist/new'
    end
    
    inputs = {
      :name      => params[:name],
      :category1 => params[:category1],
      :category2 => params[:category2],
      :tag       => params[:tag],
      :vote      => params[:vote],
      :comment   => params[:comment],
      :platform  => params[:platform]
    }
    
    if inputs[:name].empty?
      @output = Status::EMPTY_REQUIRED_FIELD
      return renderize :'gamelist/new'
    elsif current_user.permission_level.zero?
      @output = Status::FORBIDDEN
      return renderize :'gamelist/new'
    end
    
    inputs.delete_if { |key, val| val.nil? || val.empty? }
    inputs[:started] = Date.new params[:year].to_i, params[:month].to_i, params[:day].to_i
    
    game = current_user.games.new(
      :name      => inputs[:name],
      :category1 => inputs[:category1],
      :category2 => inputs[:category2],
      :vote      => inputs[:vote],
      :comment   => inputs[:comment],
      :platform  => inputs[:platform],
      :started   => inputs[:started]
    )
    
    @output = game.save ? Status::SUCCESS : { :status => Status::FAIL, :error => game.errors }
    return renderize :'gamelist/new'
  end
  
  # ---
  get '/gamelist/:username/:id/edit/?' do
    unless logged_in?
      @output = Status::NOT_LOGGED
      return renderize :'gamelist/edit'
    end
    
    unless current_user.username == params[:username]
      @output = Status::FORBIDDEN
      return renderize :'gamelist/edit'
    end
    
    game = Game.first(:id => params[:id], :user => { :username => current_user.username }) # user.games.all is bugged
    
    if game.nil?
      @output = Status::NOT_FOUND
      return renderize :'gamelist/edit'
    end
    
    @game = game
    return renderize :'gamelist/edit'
  end
  
  post '/gamelist/:username/:id/edit/?' do
    unless logged_in?
      @output = Status::NOT_LOGGED
      return renderize :'gamelist/new'
    end
    
    unless current_user.username == params[:username]
      @output = Status::FORBIDDEN
      return renderize :'gamelist/new'
    end
    
    inputs = {
      :name      => params[:name],
      :category1 => params[:category1],
      :category2 => params[:category2],
      :tag       => params[:tag],
      :vote      => params[:vote],
      :comment   => params[:comment],
      :platform  => params[:platform]
    }
    
    game = Game.first(:id => params[:id], :user => { :username => current_user.username }) # user.games.all is bugged
    
    if inputs[:name].empty?
      @output = Status::EMPTY_REQUIRED_FIELD
      return renderize :'gamelist/edit'
    elsif game.nil?
      @output = Status::NOT_FOUND
      return renderize :'gamelist/edit'
    end
    
    inputs.delete_if { |key, val| val.empty? }
    inputs[:started] = Date.new params[:year].to_i, params[:month].to_i, params[:day].to_i
    
    update = game.update(
      :name      => inputs[:name],
      :category1 => inputs[:category1],
      :category2 => inputs[:category2],
      :vote      => inputs[:vote],
      :tag       => inputs[:tag],
      :comment   => inputs[:comment],
      :platform  => inputs[:platform],
      :started   => inputs[:started]
    )
    
    @output = update ? Status::SUCCESS : Status::FAIL
    return renderize :'gamelist/edit'
  end
  
  # ---  
  post '/gamelist/:username/delete/?' do
    unless logged_in?
      @output = Status::NOT_LOGGED
      return renderize :'gamelist/delete'
    end
    
    unless current_user.username == params[:username]
      @output = Status::FORBIDDEN
      return renderize :'gamelist/delete'
    end
    
    game  = Game.first(:id => params[:id], :user => { :username => current_user.username }) # user.games.all is bugged
    
    if game.nil?
      @output = Status::FORBIDDEN
      return renderize :'gamelist/delete'
    elsif current_user.permission_level.zero?
      @output = Status::FORBIDDEN
      return renderize :'gamelist/delete'
    end    
    
    @output = game.destroy ? Status::SUCCESS : Status::FAIL
    return renderize :'gamelist/delete'
  end
	
	# ---
  get '/gamelist/:username/:property/:order/?' do
    @username = params[:username]
    user      = User.first(:username => params[:username])
    
    if user.nil?
      @output = Status::NOT_FOUND
      return renderize :'gamelist/index'
    end
    
    order = ((params[:order] == 'asc' || params[:order] == 'desc') && Game.is_property?(params[:property])) ? params[:property].to_sym.send(params[:order]) : :name.asc
    @games  = Game.all(:order => [order], :user => { :username => params[:username] }) # user.games.all is bugged
    
    @own    = current_user.username == params[:username]
    @owner  = user
    return renderize :'gamelist/index'
  end
  
  get '/gamelist/:username/?' do
    @username = params[:username]
    user      = User.first(:username => params[:username])
    
    if user.nil?
      @output = Status::NOT_FOUND
      return renderize :'gamelist/index'
    end
    
    @games  = Game.all(:order => [:name.asc], :user => { :username => params[:username] }) # user.games.all is bugged
    @own    = current_user.username == params[:username]
    @owner  = user
    return renderize :'gamelist/index'
  end
  
end
