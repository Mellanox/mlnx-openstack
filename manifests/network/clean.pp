class mellanox_openstack::network::clean {
    include mellanox_openstack::network::clean_network
    include mellanox_openstack::common::clean_neutron_server
}


class mellanox_openstack::network::clean_network {

    if $network_mode == 'ib' {
        service { 'openvswitch':
            ensure  =>  stopped,
            enable  =>  false
        }
    }
}
