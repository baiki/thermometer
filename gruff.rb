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

puts SOFTWARE_NAME + ' ' + SOFTWARE_VERSION
puts 'Start date: ' + start_date
puts 'End date  : ' + date
print 'Starting calculations...'

CSV.foreach(actual_file) do |row|
  next if row[2].to_f >= 38.0
  i += 1
  @total_readings = i
  next if i.odd?
  if row[0] != date_compare
    tmp_date = row[0][8..-1] #[5..-1].split('.').reverse.join('.')
    print '.'
    graph_date.merge!(Hash[i/2, tmp_date])
    date_compare = row[0]
  end
  temp_celcius.push(row[2].to_f)
#  break if i == 1000
end

puts ' Done.'
print 'Generating chart...'

g = Gruff::Line.new(600)
g.hide_dots = true
g.title_font_size = 30
g.legend_font_size = 22
g.title = 'History from ' + start_date.split('.').reverse.join('.') + ' - ' + date.split('.').reverse.join('.') + ', ' + time
g.data('Temperature in °C, date as DD and time as UTC+02:00', temp_celcius)
g.labels = graph_date
g.write('public/temperature_celcius_chart.png')

puts ' Done.'

statistics = File.open(statistics_file, 'w+')
statistics.puts(@total_readings)
statistics.close

puts 'Software ended.'
exit
