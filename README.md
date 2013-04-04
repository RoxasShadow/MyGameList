>Stalled

MyAnimeList clone for gamer in development.

```
git clone https://github.com/RoxasShadow/Perpetual && cd Perpetual-master && gem build *.gemspec && gem install *.gem && cd ../ && rm -rf Perpetual-master
sudo gem install bundler
git clone https://github.com/RoxasShadow/MyGameList
cd MyGameList
# Configure config/db.yml with your MySQL login data (however, you can use another DBMS just changing some rows in mygamelist.rb)
sudo apt-get install libmysqlclient-dev # change it according to your package manager
bundle install
thin -R config.ru -p 4567 start
# http://localhost:4567
```

In order to have a documentation about the public APIs execute the follow commands.

```
sudo gem install rdoc-sinatra
rdoc app/controllers/*
cd doc
```
