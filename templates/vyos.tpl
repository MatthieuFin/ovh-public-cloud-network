#cloud-config
// Configure kernel ECMP params (TODO there is a vyos config which set this for us should read the doc)
write_files:
  - path: /etc/sysctl.d/90-multipath.conf
    owner: root:vyattacfg
    permissions: '644'
    content: |
        net.ipv4.fib_multipath_hash_policy = 1
        net.ipv4.fib_multipath_use_neigh = 1
        net.ipv6.fib_multipath_hash_policy = 1

vyos_config_commands:
  # create user
  - set system login user '${admin_username}'
  - set system login user ${admin_username} authentication plaintext-password '${admin_password}'
  - set system login user ${admin_username} level admin
  # enable ssh
  - set service ssh port '22'
  # setup api https for terraform provider
  - set service https certificates system-generated-certificate
  - set service https api port '8080'
  - set service https api keys id tf key '${api_key}'
  - set service https virtual-host rtr01 listen-port '11443'
  # TODO replace 0.0.0.0 by ipmi interface
  - set service https virtual-host rtr01 listen-adress '0.0.0.0'
  - set service https api-restrict virtual-host 'rtr01'
#  # setup VPN/crossco static route
#  - set protocols static route 192.168.0.0/24 next-hop '10.14.0.xx'
