#!/usr/bin/env ruby

=begin
Copyright © 2013 Baiki <dot_baiki@yahoo.com>
This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the COPYING file for more details.
=end

#%w[sinatra thin data_mapper dm-sqlite-adapter bcrypt].each { |g| require g }
%w[sinatra thin].each { |g| require g }

SOFTWARE_NAME     = 'Thermometer'
SOFTWARE_VERSION  = 'v0.18'

configure do
  set :bind, '0.0.0.0'
  set :port, 1234
  enable :logging
#  enable :sessions
  use Rack::Session::Cookie, :key => 'thermometer.session',
                             :path => '/',
                             :expire_after => 900,
                             :secret => 'hH76Dvj90Lxb157aaPUw'
end

helpers do
  def link(name)
    case name
    when :home then '/'
    when :thermometer then '/thermometer'
    when :chart then '/chart'
    when :logout then '/logout'
    else "/"
    end
  end

  def get_readings
    actual_file = Dir.glob("data/messwerte*").max_by {|f| File.mtime(f)}
    @temp_date, @temp_time, @temp_celcius = `tail -n 1 #{actual_file}`.rstrip.split(',')
    @cpu_temp = (`cat /sys/class/thermal/thermal_zone0/temp`.to_f / 1000).round(1)
  end

  def get_statistics
    statistics = IO.read('data/gruff-statistics')
    @total_readings = statistics.chomp
  end

  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Protected Access"'
    halt 401, "Ouch... not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['1', '1']
  end
end

before do
end

after do
end

get '/' do
  redirect link(:thermometer)
end

get '/thermometer' do
  get_readings
  get_statistics
  erb :thermometer
end

get '/chart' do
  get_readings
  get_statistics
  erb :chart
end

get '/logout' do
  get_readings
  session.clear
  erb :logout
end

get '/admin' do
  protected!
  get_readings
  erb :admin
end

not_found do
  "Ouch... not found."
end

error do
  "Ouch... error."
end
