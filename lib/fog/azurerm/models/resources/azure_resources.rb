module Fog
  module Resources
    class AzureRM
      # This class is giving implementation of all/list and get.
      class AzureResources < Fog::Collection
        attribute :tag_name
        attribute :tag_value
        model AzureResource

        def all
          unless tag_name.nil? && tag_value.nil?
            resources = []
            service.list_tagged_resources(tag_name, tag_value).each do |resource|
              resources << AzureResource.parse(resource)
            end
            resources.inspect
            return load(resources)
          end
          nil
        end

        def get(resource_id)
          all.find { |f| f.id == resource_id }
        end
      end
    end
  end
end
