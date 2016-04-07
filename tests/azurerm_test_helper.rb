# rubocop:disable LineLength
# rubocop:disable AbcSize
def azurerm_resources_service
  Fog::Resources::AzureRM.new
end

def azurerm_dns_service
  Fog::DNS::AzureRM.new
end

def azurerm_network_service
  Fog::Network::AzureRM.new
end

def azurerm_storage_service
  Fog::Storage::AzureRM.new
end

def storage_account_attributes
  {
    name: storage_account_name,
    location: location,
    resource_group_name: rg_name
  }
end

def rg_attributes
  {
    name: rg_name,
    location: location
  }
end

def storage_account_name
  'fog-test-storage-account'
end

def rg_name
  'fog-test-resource-group'
end

def zone_name
  'fogtestzone.com'
end

def rs_record_type
  'A'
end

def rs_name
  'fogtestrecordset'
end

def rs_test_records
  ['1.2.3.4', '1.2.3.3']
end

def rs_ttl
  60
end

def location
  'West US'
end

def fog_storage_account
  storage_account = azurerm_storage_service.storage_accounts.find { |sa| sa.name == storage_account_name && sa.resource_group_name == rg_name }
  unless storage_account
    storage_account = azurerm_storage_service.storage_accounts.create(storage_account_attributes)
  end
  storage_account
end

def pubpic_ip_type
  'Static'
end

def public_ip_name
  'fogtestpublicip'
end

def fog_resource_group
  resource_group = azurerm_resources_service.resource_groups.find { |rg| rg.name == rg_name }
  unless resource_group
    resource_group = azurerm_resources_service.resource_groups.create(rg_attributes)
  end
  resource_group
end

def fog_zone
  zone = azurerm_dns_service.zones.find { |z| z.name == zone_name && z.resource_group == rg_name }
  unless zone
    zone = azurerm_dns_service.zones.create(name: zone_name, resource_group: rg_name)
  end
  zone
end

def fog_record_set
  rset = azurerm_dns_service.record_sets(resource_group: rg_name, zone_name: zone_name).find { |rs| rs.name == rs_name && rs.type == rs_record_type }
  unless rset
    rset = azurerm_dns_service.record_sets.create(
      name: rs_name, resource_group: rg_name, zone_name: zone_name, records: rs_test_records, type: rs_record_type, ttl: rs_ttl
    )
  end
  rset
end

def fog_public_ip
  pubip = azurerm_network_service.public_ips({:resource_group => rg_name}).find{|pip| pip.name == public_ip_name}
  unless pubip
    pubip = azurerm_network_service.public_ips.create(
        :name => public_ip_name, :resource_group => rg_name, :location => location, :type => pubpic_ip_type
    )
  end
  pubip
end

def rg_destroy
  resource_group = azurerm_resources_service.resource_groups.find { |rg| rg.name == rg_name }
  resource_group.destroy if resource_group
end

def zone_destroy
  zone = azurerm_dns_service.zones.find { |z| z.name == zone_name }
  zone.destroy if zone
end

def record_set_destroy
  rset = azurerm_dns_service.record_sets(resource_group: rg_name, zone_name: zone_name).find { |rs| rs.name == rs_name }
  rset.destroy if rset
end

def public_ip_destroy
  pubip = azurerm_network_service.public_ips({:resource_group => rg_name}).find{|pip| pip.name == public_ip_name}
  pubip.destroy if pubip
end

def storage_account_destroy
  storage_account = azurerm_storage_service.storage_accounts.find { |sa| sa.name == storage_account_name }
  storage_account.destroy if storage_account
end

at_exit do
  unless Fog.mocking?
    record_set_destroy
    storage_account_destroy
    zone_destroy
    public_ip_destroy
    rg_destroy
  end
end
