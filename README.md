This is a simple sinatra app that can be deployed to heroku or any other 
rack-compatible service.

Get the require gems by running 

    bundle install

Fire up the server with:

    OAUTH2_CLIENT_ID=... OAUTH2_CLIENT_SECRET=... rackup config.ru

Be sure to register an app that uses the correct port and address as 
the ones you actually have in this app, or the oauth process won't work.


