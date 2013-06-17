#!/usr/bin/env ruby

# baiki 2013-06-17

%w[sinatra thin].each { |g| require g }

configure do
  set :bind, '0.0.0.0'
  set :port, 1234
  enable :logging
  #enable :sessions #uncomment if not using Rack::Session::Cookie
  use Rack::Session::Cookie, :key => 'rack.session',
                             :path => '/',
                             :expire_after => 43200,
                             :secret => 'hH76Dvj90Lxb157aaPUw'
end

helpers do
  def link(name)
    case name
    when :home then '/'
    when :thermometer then '/thermometer'
    when :logout then '/logout'
    else "/"
    end
  end
end

SOFTWARE_NAME     = 'Thermometer'
SOFTWARE_VERSION  = 'v0.12'

before do
end

after do
end

get '/' do
  redirect link(:thermometer)
end

get '/thermometer' do
  actual_file = Dir.glob("data/*").max_by {|f| File.mtime(f)}
  @temp_date, @temp_time, @temp_celcius = `tail -n 1 #{actual_file}`.rstrip.split(',')
  erb :thermometer
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
