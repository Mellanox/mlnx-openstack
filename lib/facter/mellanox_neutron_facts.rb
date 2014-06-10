Facter.add(:neutron_port) do
  setcode do
    `ibdev2netdev |grep Up | head -1 | awk {'print $5'}`.gsub("\n","")
  end
end

Facter.add(:neutron_port_ib) do
  setcode do
    `ibdev2netdev |grep Up | grep -i ib | head -1 | awk {'print $5'}`.gsub("\n","")
  end
end

Facter.add(:my_inband) do
  setcode do
    inband_interface = `ibdev2netdev |grep Up | grep -i ib | head -1 | awk {'print $5'}`.gsub("\n","")
    if inband_interface.empty?
        inband_interface = `ibdev2netdev |grep Up | head -1 | awk {'print $5'}`.gsub("\n","")
    end
    `ifconfig #{inband_interface} |grep 'inet addr'|awk {'print $2'}`.split(':')[1].gsub("\n","")
  end
end

Facter.add(:my_outband) do
  setcode do
    `hostname -i`.gsub("\n","")
  end
end

Facter.add(:my_fqdn) do
  setcode do
    `hostname --fqdn`.gsub("\n","")
  end
end
