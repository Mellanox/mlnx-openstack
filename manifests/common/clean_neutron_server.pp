class mellanox_openstack::common::clean_neutron_server {

    # Stop neutron-server services
    service { 'neutron-server':
        ensure  =>  stopped
    }
    service { 'neutron-openvswitch-agent':
        ensure  =>  stopped,
        enable  =>  false
    }

}
