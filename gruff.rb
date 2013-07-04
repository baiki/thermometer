#!/usr/bin/env ruby
# encoding: UTF-8

=begin
Copyright © 2013 Baiki <dot_baiki@yahoo.com>
This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the COPYING file for more details.
=end

%w[gruff csv].each { |g| require g }

SOFTWARE_NAME    = 'Gruff Chart Generator'
SOFTWARE_VERSION = 'v0.16'

puts 'Starting: ' + SOFTWARE_NAME + ' ' + SOFTWARE_VERSION

actual_file = Dir.glob("data/messwerte*").max_by {|f| File.mtime(f)}
date, time, celcius = `tail -n 1 #{actual_file}`.rstrip.split(',')
temp_celcius = Array.new()
graph_date = Hash.new()
date_compare = ''
i = 0

puts 'Software started.'

CSV.foreach(actual_file) do |row|
  i += 1
  if row[0] != date_compare
    tmp_date = row[0][5..-1].split('.').reverse.join('.')
    p tmp_date
    graph_date.merge!(Hash[i, tmp_date])
    date_compare = row[0]
  end
  temp_celcius.push(row[2].to_f)
end

puts 'Days calculated.'
puts 'Generating chart...'

g = Gruff::Line.new(600)
g.title = 'Temperature History Until Today ' + time
g.data('Temperature in °C, date as DD.MM and time as UTC+02:00', temp_celcius)
g.labels = graph_date
g.write('public/temperature_celcius_chart.png')

puts 'Chart is ready.'
exit
