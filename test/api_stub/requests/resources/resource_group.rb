module ApiStub
  module Requests
    module Resources
      # Mock class for Resource Group Requests
      class ResourceGroup
        def self.create_resource_group_response
          MsRestAzure::AzureOperationResponse.new(MsRest::HttpOperationRequest.new('', '', ''), Faraday::Response.new)
        end

        def self.list_resource_group_response
          body = '{
            "value": [ {
              "id": "/subscriptions/########-####-####-####-############/resourceGroups/fog-test-rg",
              "name": "fog-test-rg",
              "location": "westus",
              "tags": {
                "tagname1": "tagvalue1"
              },
              "properties": {
                "provisioningState": "Succeeded"
              }
            } ],
            "nextLink": "https://management.azure.com/subscriptions/########-####-####-####-############/resourcegroups?api-version=2015-01-01&$skiptoken=######"
          }'
          result = MsRestAzure::AzureOperationResponse.new(MsRest::HttpOperationRequest.new('', '', ''), Faraday::Response.new)
          result.body = Azure::ARM::Resources::Models::ResourceGroupListResult.deserialize_object(JSON.load(body))
          result
        end
      end
    end
  end
end
