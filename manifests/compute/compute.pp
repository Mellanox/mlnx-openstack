class mellanox_openstack::compute::compute {

    # Add yum repo
    yumrepo { "mlnx-havana":
       baseurl   =>  "http://www.mellanox.com/downloads/solutions/openstack/havana/repo/mlnx-havana",
       descr     =>  "Mellanox Openstack",
       enabled   =>  0,
       gpgcheck  =>  0
    }

    package { 'eswitchd':
        ensure   =>  installed,
        require  =>  Yumrepo['mlnx-havana']
    }
    package { 'mlnxvif':
        ensure  =>  installed,
        require =>  Yumrepo['mlnx-havana']
    }
    package { 'openstack-neutron-mellanox':
        ensure   =>  installed,
        require  =>  Yumrepo['mlnx-havana']
    }

    # Set common parameters and order to File lines
    File_line {
        path    =>  '/etc/nova/nova.conf',
        require =>  [ Package['eswitchd'],
                      Package['mlnxvif'],
                      Package['openstack-neutron-mellanox'] ],
        before  =>  [ Service['openstack-nova-compute'],
                      Service['eswitchd'],
                      Service['neutron-mlnx-agent'] ]
    }

    # Set order to File
    File {
        before  =>  [ Service['openstack-nova-compute'],
                      Service['eswitchd'],
                      Service['neutron-mlnx-agent'] ]
    }

    # Change /etc/eswitchd/eswitchd.conf
    file { "eswitchd.conf":
        path     =>  "/etc/eswitchd/eswitchd.conf",
        content  =>  template('mellanox_openstack/mlnx_eswitchd_template.erb'),
        require  =>  Package['eswitchd']
    }

    # Ensure lines in /etc/nova/nova.conf
    $file_lines = {
        'nova_compute_driver' =>  {
            line   =>  'compute_driver=nova.virt.libvirt.driver.LibvirtDriver',
            match  =>  "^compute_driver\s*="
         },
        'nova_libvirt_vif_driver'  =>  {
            line   =>  'libvirt_vif_driver=mlnxvif.vif.MlxEthVIFDriver',
            match  =>  "^libvirt_vif_driver\s*="
         },
        'nova_security_group_api'  =>  {
            line   =>  'security_group_api=nova',
            match  =>  "^security_group_api\s*="
        },
        'nova_connection_type'  =>  {
            line   =>  'connection_type=libvirt',
            match  =>  "^connection_type\s*="
        }
    }
    create_resources( file_line, $file_lines )

    # Change mlnx_conf.ini
    file { 'mlnx_conf.ini':
        path     =>  "/etc/neutron/plugins/mlnx/mlnx_conf.ini",
        content  =>  template('mellanox_openstack/mlnx_conf_template.erb'),
        require  =>  Package['openstack-neutron-mellanox']
    }

    # Start services
    service { 'neutron-openvswitch-agent':
        ensure  =>  stopped,
        enable  =>  false,
        before  =>  Service['eswitchd']
    }
    service { 'eswitchd':
        ensure  =>  running,
        enable  =>  true,
        notify  =>  Service['neutron-mlnx-agent']
    }
    service { 'neutron-mlnx-agent':
        ensure  =>  running,
        enable  =>  true,
        notify  =>  Service['openstack-nova-compute']
    }
    service { 'openstack-nova-compute':
        ensure  =>  running,
        enable  =>  true
    }


    if $network_mode == 'ib' {

        service { 'openibd':
            ensure  =>  running,
            enable  =>  true,
            before  =>  Service['eswitchd']
        }

        if $virt_mode == 'pv' {
            # Ensure IP over IB
            file_line { 'openib.conf':
                path    =>  '/etc/infiniband/openib.conf',
                line    =>  'E_IPOIB_LOAD=yes',
                match   =>  "^#*E_IPOIB_LOAD\s*=",
                notify  =>  Service['openibd']
            }

            package { 'openstack-neutron-linuxbridge':
                ensure   =>  installed,
                require  =>  Service['openibd']
            }
            file { "linuxbridge_conf.ini":
                path     =>  "/etc/neutron/plugins/linuxbridge/linuxbridge_conf.ini",
                content  =>  template('mellanox_openstack/mlnx_linuxbridge_template.erb'),
                require  =>  Package['openstack-neutron-linuxbridge'],
                notify   =>  Service['neutron-linuxbridge-agent']
            }
            service { 'neutron-linuxbridge-agent':
                ensure   =>  running,
                enable   =>  true,
                require  =>  Package['openstack-neutron-linuxbridge']
            }
       }
    }

}

