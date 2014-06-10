
class mellanox_openstack::controller::clean {
    include mellanox_openstack::common::clean_neutron_server
    include mellanox_openstack::controller::clean_mysql
}

class mellanox_openstack::controller::clean_mysql {

    if $network_mode == 'ib' {
        mysql_database { 'neutron':
            ensure  =>  'absent',
        }
    }
}
