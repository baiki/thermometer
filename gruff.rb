#!/usr/bin/env ruby
# encoding: UTF-8

=begin
Copyright © 2013 Baiki <dot_baiki@yahoo.com>
This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the COPYING file for more details.
=end

%w[gruff csv].each { |g| require g }

SOFTWARE_NAME       = 'Gruff Chart Generator'
SOFTWARE_VERSION    = 'v0.18'

actual_file         = Dir.glob('data/messwerte*').max_by {|f| File.mtime(f)}
statistics_file     = 'data/gruff-statistics'
date, time, celcius = `tail -n 1 #{actual_file}`.rstrip.split(',')
start_date          = `head -n 1 #{actual_file}`.rstrip.split(',')[0]
temp_celcius        = Array.new()
graph_date          = Hash.new()
date_compare        = ''
i                   = 0

puts 'Starting: ' + SOFTWARE_NAME + ' ' + SOFTWARE_VERSION
puts 'According to the file...'
puts 'Start date: ' + start_date
puts 'End date  : ' + date
puts 'Starting calculations...'

CSV.foreach(actual_file) do |row|
  i += 1
  @total_readings = i
  next if i.odd?
  if row[0] != date_compare
    tmp_date = row[0][5..-1].split('.').reverse.join('.')
    p tmp_date
    graph_date.merge!(Hash[i/2, tmp_date])
    date_compare = row[0]
  end
  temp_celcius.push(row[2].to_f)
#  break if i == 100
end

puts 'Days calculated.'
puts 'Generating chart...'

g = Gruff::Line.new(600)
g.title = 'Histroy from ' + start_date.split('.').reverse.join('.') + ' - ' + date.split('.').reverse.join('.') + ', ' + time
g.data('Temperature in °C, date as DD.MM and time as UTC+02:00', temp_celcius)
g.labels = graph_date
g.write('public/temperature_celcius_chart.png')

puts 'Chart is ready.'

statistics = File.open(statistics_file, 'w+')
statistics.puts(@total_readings)
statistics.close

puts 'Software ended.'
exit
