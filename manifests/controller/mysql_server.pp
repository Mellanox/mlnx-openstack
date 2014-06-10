class mellanox_openstack::controller::mysql_server {

    file_line { 'nova.conf':
        path    =>  '/etc/nova/nova.conf',
        line    =>  'security_group_api=nova',
        match   =>  "^security_group_api\s*=",
        notify  =>  Service['openstack-nova-conductor']
    }

    service { 'openstack-nova-conductor':
        ensure  =>  running,
        enable  =>  true
    }

    class { '::mysql::server':
        root_password     =>  $mlnx_neutron_root_password,
        override_options  =>  {
            'mysqld'  =>  {
                'max_connections'  =>  '1024',
                bind_address       =>  '0.0.0.0'
            }
        }
    }

    mysql::db { 'neutron':
        ensure    =>  present,
        user      =>  'neutron',
        password  =>  $mlnx_neutron_root_password,
        host      =>  '%',
        grant     =>  ['ALL'],
        require   =>  Service['openstack-nova-conductor'],
        before    =>  Mysql_grant['root@%/*.*']
    }

    mysql_grant { 'root@%/*.*':
        ensure      =>  'present',
        options     =>  ['GRANT'],
        privileges  =>  ['ALL'],
        table       =>  '*.*',
        user        =>  'root@%',
        before      =>  Mysql_grant['neutron@%/*.*']
    }

    mysql_grant { 'neutron@%/*.*':
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['ALL'],
        table      => '*.*',
        user       => 'neutron@%',
        before     => Mysql_grant['cinder@%/*.*']
    }

    mysql_grant { 'cinder@%/*.*':
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['ALL'],
        table      => '*.*',
        user       => 'cinder@%'
    }

}

