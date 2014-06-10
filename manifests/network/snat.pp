class mellanox_openstack::network::snat {

    if $use_namespaces == 'false' {
        file { "neutron_linuxbridge_modules":
            path     =>  "/etc/sysconfig/modules/openstack-neutron-linuxbridge.modules",
            content  =>  template('mellanox_openstack/neutron_linuxbridge_modules_template.erb'),
            mode => 755
        }
    }

}

