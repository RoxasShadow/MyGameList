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

class User
  include DataMapper::Resource

  property	:id,                Serial
            
  property	:username,          String,
            :unique             => true,
						:length             => 4..16,
						:format             => /\A[a-zA-Z0-9_]*\z/
  
  property  :email,             String,
            :unique             => true,
            :length             => 5..40,
            :format             => :email_address
  
  property  :presentation,      Text
						
  property  :permission_level,  Integer, :default => 1
  
  property	:hashed_password,   String
  
  property	:lost_password,     String
            
  property	:tmp_password,      String
  
  property	:salt,              String
  
  property  :secret,            String,
            :unique             => true,
            :length             => 10
            
  property	:created_at,        DateTime
  
  property	:updated_at,        DateTime
  
  has n, :games
  
  before :save, :purge
  
  def purge
  	self.username     = Rack::Utils.escape_html self.username
  	self.presentation = Rack::Utils.escape_html self.presentation
  end

  attr_accessor             :password,              :password_confirmation
  validates_presence_of     :password_confirmation, :unless => Proc.new { |t| t.hashed_password }
  validates_presence_of     :password,              :unless => Proc.new { |t| t.hashed_password }
  validates_confirmation_of :password
  
  def password=(pass)
    @password             = pass
    self.salt             = Perpetual::String::Miscs::random if !self.salt
    self.hashed_password  = (@password + self.salt).sha1
  end
  
  def admin?
    self.permission_level == -1
  end
  
  def site_admin?
    self.id == 1
  end
  
  def User.password_lost(user)
    return user ? user.update(:lost_password => Perpetual::String::Miscs::random, :tmp_password  => Perpetual::String::Miscs::random(6)) : false
  end
  
  def User.password_recover(user)
    return false if @user.tmp_password.empty?
    
    return @user ? @user.update(:password => @user.tmp_password, :password_confirmation => @user.tmp_password, :lost_password => '', :tmp_password => '') : false
  end
  
  def User.authenticate(username, pass)
    current_user = User.first(:username => username)
    return nil          if current_user.nil?
    return current_user if (pass + current_user.salt).sha1 == current_user.hashed_password
    nil
  end
  
  protected
  def method_missing(m, *args)
    false
  end
  
end
