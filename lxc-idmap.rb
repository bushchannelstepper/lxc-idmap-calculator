#!/usr/bin/env ruby

require './LxcIdMap'

puts 'Base offset (100000)'
offset = gets.chomp

puts 'List of UIDs to transpose'
puts 'e.g 1969 420-426 2084-2525'
uid_input = gets.chomp
uidmap = LxcIdMap.new('u', uid_input)

puts 'List of GIDs to transpose'
gid_input = gets.chomp
gidmap = LxcIdMap.new('g', gid_input)

puts
puts '# === /etc/pve/lxc/0000.conf ======'
puts

uidmap.render_lxc
puts '# ---------------------------------'
gidmap.render_lxc
puts '# ---------------------------------'
puts

if uid_input then
  puts '# Ensure these lines are present in'
  puts '# === /etc/subuid ================='
  uidmap.render_subid

  puts '# ---------------------------------'
  puts
end

if gid_input then
  puts '# Ensure these lines are present in'
  puts '# === /etc/subgid ================='
  gidmap.render_subid

  puts '# ---------------------------------'
  puts
end