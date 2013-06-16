#!/usr/bin/env ruby

# baiki 2013

%w[sinatra thin].each { |g| require g }

configure do
  enable :sessions
  enable :logging
end

helpers do
  def link(name)
    case name
    when :root then '/'
    when :thermometer then '/thermometer'
    when :logout then '/logout'
    else "/"
    end
  end
end

SOFTWARE_NAME     = 'Thermometer'
SOFTWARE_VERSION  = 'v0.01'

before do
end

after do
end

get '/' do
  redirect link(:thermometer)
end

get '/thermometer' do
  erb :thermometer
end

post '/client/create' do
  client = Client.new
  client.first_name  = params[:first_name].capitalize
  client.middle_name = params[:middle_name].capitalize
  client.last_name   = params[:last_name].capitalize
  client.birthdate   = params[:birthdate]
  client.gender      = params[:gender]
  if client.save
    ##### if true notify, write log
    redirect link(:root)
  else
    ##### if false: notify, raise error, write log
    redirect link(:root)
  end
end

get '/client/search' do
  if Client.count <= 0 then
    redirect link(:client_create)
  else
    @clients = Client.all(:order => :id.desc, :limit => CLIENTS_LIMIT)
  end
  erb :client_search
end

delete '/client/delete/:id' do
  Client.get(params[:id]).destroy
  redirect link(:client_search)
end

get '/logout' do
  session.clear
end

not_found do
  "Ouch... not found."
end

error do
  "Ouch... error."
end
