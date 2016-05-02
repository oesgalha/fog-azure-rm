module Fog
  module Network
    class AzureRM
      # Real class for Network Request
      class Real
        def delete_public_ip(resource_group, name)
          Fog::Logger.debug "Deleting PublicIP #{name} from Resource Group #{resource_group}."
          begin
            promise = @network_client.public_ipaddresses.delete(resource_group, name)
            response = promise.value!
            Fog::Logger.debug "PublicIP #{name} Deleted Successfully."
            response
          rescue  MsRestAzure::AzureOperationError => e
            msg = "Exception deleting Public IP #{name} in Resource Group: #{resource_group}. #{e.body['error']['message']}"
            raise msg
          end
        end
      end

      # Mock class for Network Request
      class Mock
        def delete_public_ip(_resource_group, _name)
        end
      end
    end
  end
end
