
class mellanox_openstack::controller::controller {

    service { 'neutron-openvswitch-agent':
        ensure  =>  stopped,
        enable  =>  false
    }

    $services = [ 'openstack-nova-api',
                  'openstack-nova-cert',
                  'openstack-nova-console',
                  'openstack-nova-consoleauth',
                  'openstack-nova-scheduler',
                  'openstack-nova-novncproxy',
                  'openstack-nova-xvpvncproxy' ]

    service { $services:
        ensure   =>  running,
        enable   =>  true,
        require  =>  Service['neutron-openvswitch-agent']
    }

    File_line {
        path    =>  '/etc/nova/nova.conf',
        notify  =>  [ Service[$services] ]
    }

    if $network_mode == 'eth' {
        $nova_conf_file_lines = {
            'nova_conf_security'  =>  {
                line   =>  'security_group_api=nova',
                match  =>  "^security_group_api\s*="
            },
            'nova_conf_volume_drivers'  =>  {
                line   =>  'libvirt_volume_drivers = iser=nova.virt.libvirt.volume.LibvirtISERVolumeDriver',
                match  =>  "^#*libvirt_volume_drivers\s*="
            },
            'nova_conf_debug'  =>  {
                line  => 'debug=false',
                match => "^debug="
            },
        }
        create_resources( file_line, $nova_conf_file_lines )
    }


    if $network_mode == 'ib' {
        $nova_conf_file_lines = {
            'nova_conf_security'  =>  {
                line   =>  'security_group_api=nova',
                match  =>  "^security_group_api\s*="
            },
            'nova_conf_volume_drivers'  =>  {
                line   =>  'libvirt_volume_drivers = iser=nova.virt.libvirt.volume.LibvirtISERVolumeDriver',
                match  =>  "^#*libvirt_volume_drivers\s*="
            },
            'nova_conf_debug'  =>  {
                line  => 'debug=false',
                match => "^debug="
            },
            'nova_conf_libvirt_vif_driver'  =>  {
                line   =>  'libvirt_vif_driver=nova.virt.libvirt.vif.NeutronLinuxBridgeVIFDriver',
                match  =>  "^libvirt_vif_driver\s*="
            }
        }
        create_resources( file_line, $nova_conf_file_lines )
    }
}

