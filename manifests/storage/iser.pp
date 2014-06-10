class mellanox_openstack::storage::iser {

    # Ensure iscsi update is installed
    $iscsi_target = "scsi-target-utils-1.0.39-v1.0.39.c1135a.x86_64"
    $iscsi_target_src = "$cloudx_agent_packages_dir/scsi-target-utils-1.0.39-v1.0.39.c1135a.x86_64.rpm"

    # Set common parameters and order to File lines
    File_line {
        path    =>  '/etc/cinder/cinder.conf',
        notify  =>  Service['openstack-cinder-volume']
    }
    $file_lines = {
        'cinder_iser_ip_address'  =>  {
            line   =>  "iser_ip_address = ${cinder_inband_ip}",
            match  =>  "^#*iser_ip_address\s*="
        },
        'cinder_volume_driver'  =>  {
            line   =>  'volume_driver = cinder.volume.drivers.lvm.LVMISERDriver',
            match  =>  "^#*volume_driver\s*="
        }
    }
    create_resources( file_line, $file_lines )

    # Download RPM and ensure package
    package { $iscsi_target:
        ensure           =>  installed,
        provider         =>  rpm,
        source           =>  $iscsi_target_src,
        install_options  =>  ['-U'],
        before           =>  File_line[keys($file_lines)],
    }

    service { 'openstack-cinder-volume':
        ensure  =>  running,
        enable  =>  true
    }
    service { 'tgtd':
        ensure  =>  running,
        enable  =>  true
    }

}

