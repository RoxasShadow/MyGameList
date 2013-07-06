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

class Game
  include DataMapper::Resource

  property	:id,          Serial
  property	:name,        String, :unique => true, :required => true
  property	:category1,   String
  property	:category2,   String
  property  :tag,         Enum[ :Playing, :Dropped, :Stalled, :Completed ], :default => :Playing
  property	:vote,        Integer, :min => 0, :max => 10
  property	:comment,     Text
  property	:platform,    String
  property	:started,     Date
  property	:finished,    Date
  property	:created_at,  DateTime
  property	:updated_at,  DateTime
  
  belongs_to :user
  
  before :save, :purge
  
  def self.is_property?(property)
    [ :id, :name, :category1, :category2, :vote, :comment, :platform, :started, :finished ].include? property.to_sym
  end
  
  def purge
	self.comment.gsub!(/"/m, '') if self.comment
  	self.name      = Rack::Utils.escape_html self.name
  	self.category1 = Rack::Utils.escape_html self.category1
  	self.category2 = Rack::Utils.escape_html self.category2
  	self.comment   = Rack::Utils.escape_html self.comment
  	self.platform  = Rack::Utils.escape_html self.platform
  end
  
  protected
  def method_missing(m, *args)
    false
  end
  
end
