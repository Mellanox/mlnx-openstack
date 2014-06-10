# Below are all the required parameters with exmple values. Uncomment and set the values.
# Possible values for each parameter are mentioned above each one.

class mellanox_openstack::params {

    # 'pv' / 'sriov'
    $virt_mode = 'sriov'

    # legal integer as a string
    $min_vlan = '2'
    $max_vlan = '10'

    # ip addresses
    $cinder_inband_ip = '1.2.3.4'
    $mysql_inband_ip = '1.2.3.5'
    $controller_outband = '10.20.30.40'

    # 'eth' / 'ib'
    $network_mode = 'eth'

    # legal string accepted by mysql
    $mlnx_neutron_root_password = 'password'

    # 'true' / 'false'
    $use_namespaces = 'false'

    # absolute path to cloudx packages directory
    $cloudx_agent_packages_dir = "/tmp/cloudx_install/packages"
}
