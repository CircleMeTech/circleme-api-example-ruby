require "sinatra/base"
      require 'pry'

OAUTH_SITE = "https://www.circleme.com"
API_SITE   = "https://api.circleme.com"
class CirclemeClient < Sinatra::Base
  enable :sessions

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html

    def pretty_json(json)
      JSON.pretty_generate(json)
    end

    def signed_in?
      !session[:access_token].nil?
    end
  end

  def client(token_method = :post)
    OAuth2::Client.new(
      ENV['OAUTH2_CLIENT_ID'] || abort('needs OAUTH_CLIENT_ID'),
      ENV['OAUTH2_CLIENT_SECRET'] || abort('needs OAUTH_CLIENT_ID'),
      :site         => OAUTH_SITE,
      :token_method => token_method
    )
  end

  def access_token
    OAuth2::AccessToken.new(client, session[:access_token], :refresh_token => session[:refresh_token])
  end

  def redirect_uri req
    "http://#{req.host_with_port}/callback"
  end

  get '/' do
    erb :home
  end

  get '/sign_in' do
    scope = params[:scope] || "basic_info"
    redirect client.auth_code.authorize_url(:redirect_uri => redirect_uri(request), :scope => scope)
  end

  get '/sign_out' do
    session[:access_token] = nil
    redirect '/'
  end

  get '/callback' do
    cb = redirect_uri(request)
    new_token = client.auth_code.get_token(params[:code], :redirect_uri => cb )
    session[:access_token]  = new_token.token
    session[:refresh_token] = new_token.refresh_token
    redirect '/'
  end

  get '/refresh' do
    new_token = access_token.refresh!
    session[:access_token]  = new_token.token
    session[:refresh_token] = new_token.refresh_token
    redirect '/'
  end

  get '/explore/:api' do
    raise "Please call a valid endpoint" unless params[:api]
    begin
      @url = API_SITE + "/v201410/#{params[:api]}"
      response = access_token.get(@url)
      @json = JSON.parse(response.body)
      erb :explore
    rescue OAuth2::Error => @error
      erb :error
    end
  end
end
