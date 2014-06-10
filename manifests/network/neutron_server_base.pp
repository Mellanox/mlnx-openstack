class mellanox_openstack::network::neutron_server_base {

    # Ensure openstack-neutron-mellanox is installed
    package { 'openstack-neutron-mellanox':
        ensure  =>  installed
    }

    File_line {
        path     =>  '/etc/neutron/neutron.conf',
        require  =>  Package['openstack-neutron-mellanox']
    }
    $file_lines = {
        '/etc/neutron/neutron.conf'  =>  {
            line   =>  'core_plugin = neutron.plugins.mlnx.mlnx_plugin.MellanoxEswitchPlugin',
            match  =>  "^core_plugin\s*="
        },
        'neutron.conf_mysql'  =>  {
           line    =>  "connection = mysql://neutron:${mlnx_neutron_root_password}@${mysql_inband_ip}/neutron",
            match  =>  "#*\s*connection\s*=\s*mysql"
        },
        'neutron.conf_debug'  =>  {
            line   =>  "debug=False",
            match  =>  "^debug\s*="
        }
    }
    create_resources( file_line, $file_lines )

    # Change mlnx_conf.ini
    file { 'mlnx_conf.ini':
        path     =>  "/etc/neutron/plugins/mlnx/mlnx_conf.ini",
        require  =>  File_line[keys($file_lines)],
        content  =>  template('mellanox_openstack/mlnx_conf_template.erb'),
    }

    # Linking /etc/neutron/plugin.ini -> /etc/neutron/plugins/mlnx/mlnx_conf.ini
    file { '/etc/neutron/plugin.ini':
        ensure   =>  link,
        target   =>  '/etc/neutron/plugins/mlnx/mlnx_conf.ini',
        require  =>  File['mlnx_conf.ini']
    }

    # Ensure neutron-server is running
    service { 'neutron-server':
        ensure   =>  stopped,
        enable   =>  false,
        require  =>  File['/etc/neutron/plugin.ini']
    }

}

