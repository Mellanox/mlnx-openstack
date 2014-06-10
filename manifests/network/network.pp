class mellanox_openstack::network::network {

    include mellanox_openstack::network::neutron_server_base

    # Add yum repo
    yumrepo { "mlnx-havana":
       baseurl => "http://www.mellanox.com/downloads/solutions/openstack/havana/repo/mlnx-havana",
       descr => "Mellanox Openstack",
       enabled => 0,
       gpgcheck => 0
    }

    # Install compute node packages
    package { 'openstack-neutron-linuxbridge': 
        ensure  =>  installed
    }
    package { 'mlnx-dnsmasq':
        ensure   =>  installed,
        require  =>  Yumrepo['mlnx-havana']
    }

    file { "linuxbridge_conf.ini":
        path     =>  "/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini",
        content  =>  template('mellanox_openstack/mlnx_linuxbridge_template.erb'),
        require  =>  Package['openstack-neutron-linuxbridge'],
        notify   =>  Service['neutron-linuxbridge-agent']
    }

    File_line {
        path  =>  '/etc/neutron/dhcp_agent.ini',
        require  =>  [ File['linuxbridge_conf.ini'],
                       Package['mlnx-dnsmasq'] ]
    }

    if $network_mode == 'eth' {
        $dhcp_agent_lines = {
            'dhcp_agent_interface'  =>  {
                line     =>  'interface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver',
                match    =>  "^interface_driver\s*=",
            },
            'dhcp_agent_namespace'  =>  {
                line     =>  'use_namespaces=False',
                match    =>  "^use_namespaces\s*=",
            },
        }
        create_resources( file_line, $dhcp_agent_lines )
    }

    if $network_mode == 'ib' {
        $dhcp_agent_lines =  {
            'dhcp_agent_interface'  =>  {
                line     =>  'interface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver',
                match    =>  "^interface_driver\s*=",
            },
            'dhcp_agent_namespace'  =>  {
                line     =>  'use_namespaces=False',
                match    =>  "^use_namespaces\s*=",
            },
            'dhcp_agent_mlnx_dnsmasq'  =>  {
                line     =>  'dhcp_driver = mlnx_dhcp.MlnxDnsmasq',
                match    =>  "^dhcp_driver\s*=",
            }
        }
        create_resources( file_line, $dhcp_agent_lines )

        service { 'openibd':
            ensure   =>  running,
            enable   =>  true,
            before   =>  [ Service['neutron-linuxbridge-agent'],
                           Service['neutron-dhcp-agent'] ],
            require  =>  File_line['openib.conf']
        }

        # IP over IB
        file_line { 'openib.conf':
            path    =>  '/etc/infiniband/openib.conf',
            line    =>  'E_IPOIB_LOAD=yes',
            match   =>  "^#*E_IPOIB_LOAD\s*=",
            notify  =>  Service['openibd']
        }
    }   

    service { 'neutron-linuxbridge-agent':
        ensure   =>  running,
        enable   =>  true,
        require  =>  File_line[keys($dhcp_agent_lines)]
    }
    service { 'neutron-dhcp-agent' :
        ensure   =>  running,
        enable   =>  true,
        require  =>  File_line[keys($dhcp_agent_lines)]
    }

    service { 'neutron-openvswitch-agent':
        ensure  =>  stopped,
        enable  =>  false,
        before  =>  Service['neutron-linuxbridge-agent'],
        require =>  File_line[keys($dhcp_agent_lines)]
    }

}

