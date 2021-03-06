require 'fog/azurerm'
require 'yaml'

########################################################################################################################
######################                   Services object required by all actions                  ######################
######################                              Keep it Uncommented!                          ######################
########################################################################################################################

azure_credentials = YAML.load_file('credentials/azure.yml')

rs = Fog::Resources::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

network = Fog::Network::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

rs.resource_groups.create(
  name: 'TestRG-LB',
  location: 'westus'
)

network.virtual_networks.create(
  name: 'testVnet',
  location: 'westus',
  resource_group: 'TestRG-LB',
  dns_servers: %w(10.1.0.0 10.2.0.0),
  address_prefixes: %w(10.1.0.0/16 10.2.0.0/16)
)

network.subnets.create(
  name: 'mysubnet',
  resource_group: 'TestRG-LB',
  virtual_network_name: 'testVnet',
  address_prefix: '10.1.0.0/24'
)

pip = network.public_ips.create(
  name: 'mypubip',
  resource_group: 'TestRG-LB',
  location: 'westus',
  public_ip_allocation_method: 'Dynamic'
)

########################################################################################################################
######################                             Create Load Balancer                           ######################
########################################################################################################################

network.load_balancers.create(
  name: 'lb',
  resource_group: 'TestRG-LB',
  location: 'westus',
  frontend_ip_configurations:
  [
    {
      name: 'fic',
      private_ipallocation_method: 'Dynamic',
      public_ipaddress_id: pip.id
    }
  ],
  backend_address_pool_names:
  [
    'pool1'
  ],
  load_balancing_rules:
  [
    {
      name: 'lb_rule_1',
      frontend_ip_configuration_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-LB/providers/Microsoft.Network/loadBalancers/lb/frontendIPConfigurations/fic",
      backend_address_pool_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-LB/providers/Microsoft.Network/loadBalancers/lb/backendAddressPools/pool1",
      protocol: 'Tcp',
      frontend_port: '80',
      backend_port: '8080',
      enable_floating_ip: false,
      idle_timeout_in_minutes: 4,
      load_distribution: 'Default'
    }
  ],
  inbound_nat_rules:
  [
    {
      name: 'RDP-Traffic',
      frontend_ip_configuration_id: "/subscriptions/#{azure_credentials['subscription_id']}/resourceGroups/TestRG-LB/providers/Microsoft.Network/loadBalancers/lb/frontendIPConfigurations/fic",
      protocol: 'Tcp',
      frontend_port: 3389,
      backend_port: 3389
    }
  ]
)

########################################################################################################################
######################                      List External Load Balancers                          ######################
########################################################################################################################

load_balancers = network.load_balancers(resource_group: 'TestRG-LB')
load_balancers.each do |load_balancer|
  Fog::Logger.debug load_balancer.name
end

########################################################################################################################
######################                        Get and Destroy Load Balancer                       ######################
########################################################################################################################

load_balancer = network.load_balancers.get('TestRG-LB', 'lb')
load_balancer.destroy

########################################################################################################################
######################                                   CleanUp                                  ######################
########################################################################################################################

pubip = network.public_ips.get('TestRG-LB', 'mypubip')
pubip.destroy

vnet = network.virtual_networks.get('TestRG-LB', 'testVnet')
vnet.destroy

resource_group = rs.resource_groups.get('TestRG-LB')
resource_group.destroy
