#!/usr/bin/env ruby

# (c) 2020-21 bushchannelstepper
# Use this script ethically at will
# Else sort yaself out

# The first number is the id in your container. The second number is the id being mapped from container to uid on the host. The third number is how many consecutive ids you want to map.  https://www.reddit.com/r/Proxmox/comments/jz5ugx/lxc_user_mapping_help/gda0q4q

def do_the_thing(uids, gids, offset)
  if offset.empty?
    offset = 100000
  else
    offset = offset.to_i
  end
  
  puts
  puts '# === /etc/pve/lxc/0000.conf ======'
  puts

  unless uids.empty? then
    format_for_lxc(uids, offset, 'u')
  end

  unless gids.empty? then
    format_for_lxc(gids, offset, 'g')
  end

  puts

  unless uids.empty? then
    puts '# Ensure these lines are present in'
    puts '# === /etc/subuid ================='
    
    format_for_subid(uids)
    puts
  end
  
  unless gids.empty? then
    puts '# Ensure these lines are present in'
    puts '# === /etc/subgid ================='
    
    format_for_subid(gids)
    puts
  end
  
  puts '# ---------------------------------'
  puts
end

def parse_input(ids_input)
  ids_input.split(' ').sort! {
    |a, b| a.split('-').first.to_i <=> b.split('-').first.to_i
  }.each { |token| parse_range token }
end

def parse_range(token)
  range = token.split('-')
  id = range.first.to_i
  range_top = range.last.to_i

  if id > range_top then
    puts "Range #{range.join('-')} looks arse backward"
    exit 1
  end
  
  range_length = range_top - id + 1

  [id, range_length]
end

def lxc_line(id_type, id_in_container, id_on_host, range_len)
  "lxc.idmap: #{id_type} #{id_in_container} #{id_on_host} #{range_len}"
end

def etc_subid_line(id_on_host, range_len)
  "root:#{id_on_host}:#{range_len}"
end

def format_for_lxc(id_list, offset, id_type)
  # first line
  puts lxc_line(id_type, 
                0, 
                offset, 
                parse_range(id_list.first).first) unless parse_range(id_list.first).first == 0

  id_list.each_with_index { |range, i|
    id_in_container, range_len = parse_range range

    # our specified 1:1 mapping range
    puts lxc_line(id_type, 
                  id_in_container, 
                  id_in_container, # yes the same again for 1:1 id map
                  range_len)

    # what's the top of the following range?
    if id_list[i + 1] then
      next_id, next_id_range_length = parse_range(id_list[i + 1])
      range_top = next_id
    else
      range_top = 65535 # we're in final iteration
    end

    # cover the default id map range up to our next specified 1:1 mapping or the end
    puts lxc_line(id_type, 
                  id_in_container + range_len, 
                  id_in_container + range_len + offset,
                  range_top - id_in_container) unless id_in_container + 1 == range_top
  }
end

def format_for_subid(id_list)
  id_list.each { |range|
    id, range_len = parse_range range
    puts etc_subid_line(id, range_len)
  }
end

# reasonable examples

# lxc.idmap = g 0 100000 1005
# lxc.idmap = g 1005 1005 1
# lxc.idmap = g 1006 101006 64530

# lxc.idmap: u 0 100000 2000
# lxc.idmap: u 2000 1000 1
# lxc.idmap: u 2001 1001 1
# lxc.idmap: u 2002 102002 63533


# do the thing

puts 'List of UIDs to transpose'
puts 'e.g 1969 420-426 2084-2525'
uids = parse_input gets.chomp

puts 'List of GIDs to transpose'
gids = parse_input gets.chomp

puts 'Base offset (100000)'
offset = gets.chomp

puts
puts 'Processing'
puts "UIDS #{uids.join(' ')}"
puts "GIDS #{gids.join(' ')}"
puts "with offset #{offset}"

do_the_thing(uids, gids, offset)



