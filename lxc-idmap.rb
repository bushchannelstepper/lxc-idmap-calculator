#!/usr/bin/env ruby

puts 'UID?'
uid = gets.chomp.to_i

puts 'GID?'
gid = gets.chomp.to_i

if !(uid > 0 && gid > 0) 
  puts 'Need non-zero values'
  exit
end

puts 'Base offset? (100000)'
offset = gets.chomp

if offset.empty?
  offset = 100000
else
  offset = offset.to_i
end

puts "Using offset #{offset}"

puts "UID #{uid} / GID #{gid}"
puts

puts "echo root:#{uid}:1 >> /etc/subuid"
puts "echo root:#{gid}:1 >> /etc/subgid"
puts
puts "idmap for (e.g) 123.conf"
puts
puts "lxc.idmap = u 0 #{offset} #{uid}"
puts "lxc.idmap = g 0 #{offset} #{gid}"
puts
puts "lxc.idmap = u #{uid} #{uid} 1"
puts "lxc.idmap = g #{gid} #{gid} 1"
puts
puts "lxc.idmap = u #{uid + 1} #{uid + offset + 1} #{65535 - uid}"
puts "lxc.idmap = g #{gid + 1} #{gid + offset + 1} #{65535 - gid}"
