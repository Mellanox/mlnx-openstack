class mellanox_openstack::controller::nova_scheduler {

    Ini_setting {
        ensure => present,
        path => '/etc/nova/nova.conf',
    }

    $nova_conf_params = { 
        "scheduler_default_filters" => {
            section => 'DEFAULT',
            setting => 'scheduler_default_filters',
            value =>  'RetryFilter,AvailabilityZoneFilter,RamFilter,CoreFilter,DiskFilter,ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter'
        },
       "cpu_allocation_ratio" => {
            section => 'DEFAULT',
            setting => 'cpu_allocation_ratio',
            value => '1.0'
        },
       "disk_allocation_ratio" => {
            section => 'DEFAULT',
            setting => 'disk_allocation_ratio',
            value => '1.0'
        },
       "ram_allocation_ratio" => {
            section => 'DEFAULT',
            setting => 'ram_allocation_ratio',
            value => '1.0'
        },
       "ram_weight_multiplier" => {
            section => 'DEFAULT',
            setting => 'ram_weight_multiplier',
            value => '0.0'
        },
       "scheduler_host_subset_size" => {
            section => 'DEFAULT',
            setting => 'scheduler_host_subset_size',
            value => '30'
        }
    }
    create_resources(Ini_setting, $nova_conf_params)

}
