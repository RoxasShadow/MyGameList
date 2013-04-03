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

	helpers do

    def current_user
      return GuestUser.new unless cookie_exists?('user')
      user = User.first(:secret => get_cookie('user'))
      return user || GuestUser.new
    end

    def logged_in?
      cookie_exists?('user') && get_cookie('user').length == 10
    end

    def user_exists?(attributes)
      !!User.first(attributes)
    end
    
  end
    
end
