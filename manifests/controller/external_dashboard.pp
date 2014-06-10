
class mellanox_openstack::controller::external_dashboard {

    $services = [ 'openstack-nova-api',
                  'openstack-nova-cert',
                  'openstack-nova-console',
                  'openstack-nova-consoleauth',
                  'openstack-nova-scheduler',
                  'openstack-nova-novncproxy',
                  'openstack-nova-xvpvncproxy' ]

    File_line {
        path    =>  '/etc/nova/nova.conf',
        notify  =>  [ Service[$services] ]
    }

    file_line { 'horizon_outband':
        path    =>  '/etc/openstack-dashboard/local_settings',
        line    =>  "ALLOWED_HOSTS = ['$my_inband', '$my_fqdn', 'localhost', '$my_outband']",
        match   =>  "^ALLOWED_HOSTS\s*=",
        notify  =>  Service['httpd']
    }

    service { 'httpd':
        ensure  =>  running,
        enable  =>  true
    }

    $file_lines = {
        'outband_proxy'  =>  {
            line   =>  "novncproxy_base_url=http://$my_outband:6080/vnc_auto.html",
            match  =>  "^#*novncproxy_base_url\s*="
        }
    }
    create_resources( file_line, $file_lines )
}
