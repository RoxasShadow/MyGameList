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

require 'sinatra/base'
require 'open-uri'
require 'pony'
require 'xml-sitemap'
require 'html_press'
require 'rack/csrf'
require 'data_mapper'
require 'dm-mysql-adapter'
require 'perpetual/string/miscs'
require 'perpetual/string/crypt'

class MyGameList < Sinatra::Base
  
  db = YAML::load File.read('config/db.yml')
  DataMapper.setup(:default, "mysql://#{db['username']}:#{db['password']}@#{db['hostname']}/#{db['database']}")
  
  configure {
    set :method_override, true
    
    use Rack::Session::Cookie,
      :path   => '/',
      :secret => 'A1 sauce 1s so good you should use 1t on a11 yr st34ksssss'
  
    use Rack::Csrf,
      :raise      => true,
      :field      => '_csrf'#,
      #:check_also => %w(GET),
      #:skip_if    => lambda { |request| request.env['REQUEST_METHOD'] == 'GET' && !request.env['REQUEST_PATH'].start_with?('/user/logout') } # csrf to all POST and just for GET /user/logout
  }
  
  Dir.glob("#{Dir.pwd}/app/helpers/*.rb") { |m| require m.chomp }
  Dir.glob("#{Dir.pwd}/app/models/*.rb") { |m| require m.chomp }; DataMapper.finalize
  Dir.glob("#{Dir.pwd}/app/controllers/*.rb") { |m| require m.chomp }

  DataMapper.auto_upgrade!
end
