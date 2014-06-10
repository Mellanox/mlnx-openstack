class mellanox_openstack::compute::ksm {

    service { 'ksm':
        ensure  =>  stopped,
        enable  =>  false,
    }
    service { 'ksmtuned':
        ensure  =>  stopped,
        enable  =>  false,
    }

}

