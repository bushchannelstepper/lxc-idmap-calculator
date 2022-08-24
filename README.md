# lxc-idmap-calculator

A script and classes for generating UID and GID mappings for unprivileged LXC containers because it's a pain in the arse to do by hand.

Now manages multiple UIDs and GIDs as well as ranges to transpose.

./lxc-idmap.rb and follow the prompts.  You could roll your own i/f around the LxcIdMap class as well.

You can enter your UIDs and UID ranges using this format: 

501 890-899 2084-2525 4000 4040

and same again for your GIDs.

It doesn't support transposing a container UID you specify to a different host UID.  Just 1:1.  You can specify your own offset for the default mapping the background, or leave it at 100000.

See https://pve.proxmox.com/wiki/Unprivileged_LXC_containers

NB:  After adding the maps to the config and starting the container, the mapping mightn't take first go.  Stop and restart the container and check again.  I had to reboot a couple of times while testing.

Please check your results when applying, this code is in beta.
