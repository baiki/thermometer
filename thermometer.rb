#!/usr/bin/env ruby

=begin
Copyright © 2013 Baiki <dot_baiki@yahoo.com>
This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the COPYING file for more details.
=end

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
SOFTWARE_VERSION  = 'v0.14'

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
  erb :logout
end

not_found do
  "Ouch... not found."
end

error do
  "Ouch... error."
end
