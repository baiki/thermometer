#!/usr/bin/env ruby
# encoding: UTF-8

=begin
Copyright © 2013 Baiki <dot_baiki@yahoo.com>
This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the COPYING file for more details.
=end

%w[gruff csv].each { |g| require g }

actual_file = Dir.glob("data/messwerte*").max_by {|f| File.mtime(f)}
temp_celcius = Array.new()
graph_date = Hash.new()
date_compare = ''
i = 0

CSV.foreach(actual_file) do |row|
  i += 1
  if row[0] != date_compare
    graph_date.merge!(Hash[i, row[0][5..-1].gsub('.', '/')])
    date_compare = row[0]
  end
  temp_celcius.push(row[2].to_f)
end

g = Gruff::Line.new(600)
g.title = 'Temperature History'
g.data('Temperature in °C', temp_celcius)
#g.data('Something', [1, 2, 4, 8, 16, 32, 64, 128])
g.labels = graph_date
g.write('public/temperature_celcius_chart.png')
