class mellanox_openstack::controller::neutron_server {

    # Ensure openstack-neutron-mellanox is installed
    package { 'openstack-neutron-mellanox':
        ensure  =>  installed
    }

    # Linking /etc/neutron/plugin.ini -> /etc/neutron/plugins/mlnx/mlnx_conf.ini
    file { '/etc/neutron/plugin.ini':
        ensure   =>  link,
        target   =>  '/etc/neutron/plugins/mlnx/mlnx_conf.ini',
        require  =>  File['mlnx_conf.ini']
    }

    # Ensure neutron-server is running
    service { 'neutron-server':
        ensure   =>  running,
        enable   =>  true,
        require  =>  File['/etc/neutron/plugin.ini']
    }


    $neutron_conf = '/etc/neutron/neutron.conf'

    if $network_mode == 'eth' {
        File_line {
            path     =>  $neutron_conf,
            require  =>  Package['openstack-neutron-mellanox'],
            notify   =>  Service['neutron-server']
        }
        $file_lines = {
            'neutron.conf_core_plugin'  =>  {
                line    =>  'core_plugin = neutron.plugins.mlnx.mlnx_plugin.MellanoxEswitchPlugin',
                match  =>  "^core_plugin\s*="
            },
            'neutron.conf_mysql'  =>  {
                line    =>  "connection = mysql://neutron:${mlnx_neutron_root_password}@${mysql_inband_ip}/neutron",
                match   =>  "^#*connection\s*="
            },
            'neutron.conf_debug'  =>  {
                line    => "debug=False",
                match   => "^debug\s*="
            }
        }
        create_resources( file_line, $file_lines )

        file { 'mlnx_conf.ini':
            path     =>  "/etc/neutron/plugins/mlnx/mlnx_conf.ini",
            require  =>  [File_line[keys($file_lines)]],
            content  =>  template('mellanox_openstack/mlnx_conf_template.erb'),
            notify   =>  Service['neutron-server']
        }
    }

    if $network_mode == 'ib' {
        File_line {
            path     =>  $neutron_conf,
            require  =>  Package['openstack-neutron-mellanox']
        }
        $file_lines = {
            'neutron.conf_core_plugin'  =>  {
                line    =>  'core_plugin = neutron.plugins.mlnx.mlnx_plugin.MellanoxEswitchPlugin',
                match  =>  "^core_plugin\s*="
            },
            'neutron.conf_mysql'  =>  {
                line    =>  "connection = mysql://neutron:${mlnx_neutron_root_password}@${mysql_inband_ip}/neutron",
                match   =>  "^#*connection\s*="
            },
            'neutron.conf_debug'  =>  {
                line    => "debug=False",
                match   => "^debug\s*="
            }
        }
        create_resources( file_line, $file_lines )

        file { 'mlnx_conf.ini':
            path     =>  "/etc/neutron/plugins/mlnx/mlnx_conf.ini",
            require  =>  [File_line[keys($file_lines)]],
            content  =>  template('mellanox_openstack/mlnx_conf_template.erb'),
        }
    }

}

