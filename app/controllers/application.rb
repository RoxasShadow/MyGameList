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

  before do
    @title        = ''
    @selected     = ''
    @welcome      = ''
    @styles       = []
    @language     = request.env['HTTP_ACCEPT_LANGUAGE']
    @current_url  = "http://#{request.env['HTTP_HOST']}#{request.env['REQUEST_URI']}"
    @domain       = "http://#{request.env['HTTP_HOST']}"
    @admin_email  = 'webmaster@giovannicapuano.net'
    @logged       = logged_in?
    
    if logged_in?
      @current_user = current_user
      @username     = current_user.username
    end
  end
	
  get '/' do
    renderize :'index'
  end
  
  get '/sitemap.xml' do
    headers['Content-Type'] = 'text/xml'
    
    users = User.all(:order => [:created_at.desc])
    XmlSitemap::Map.new(@domain.gsub('http://', '')) { |m|
      users.each { |u|
        m.add(u.username,
          #:updated  => Game.first(:order => [:created_at.desc], :user => { :username => u.username }).created_at,
          :period   => :daily,
          :priority => 1.0
        )
      }
    }.render
  end
   
  not_found do
    renderize :'notfound'
  end

  error do
    @error = env['sinatra.error']
    renderize :'error'
  end

end
