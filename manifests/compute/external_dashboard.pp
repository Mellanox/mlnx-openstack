class mellanox_openstack::compute::external_dashboard {

    File_line {
        path    =>  '/etc/nova/nova.conf',
        before  =>  [ Service['openstack-nova-compute'] ]
    }
    $file_lines = {
        'nova_proxy_base_url'  =>  {
            line   =>  "novncproxy_base_url=http://$controller_outband:6080/vnc_auto.html",
            match  =>  "^novncproxy_base_url\s*="
        },
        'nova_vnc_listen'  =>  {
            line  =>  'vncserver_listen=0.0.0.0',
            match =>  "^vncserver_listen\s*="
        },
        'nova_vnc_proxy_client'  =>  {
            line  =>  "vncserver_proxyclient_address=$my_outband",
            match =>  "^vncserver_proxyclient_address\s*="
        }
    }
    create_resources( file_line, $file_lines )
}
