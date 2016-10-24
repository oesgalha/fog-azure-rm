module Fog
  module Storage
    class AzureRM
      # This class is giving implementation of listing blobs.
      class Files < Fog::Collection
        model Fog::Storage::AzureRM::File
        attribute :directory

        def new(attributes = {})
          requires :directory
          super({ directory: directory }.merge!(attributes))
        end

        def all(options = { metadata: true })
          requires :directory
          files = []
          service.list_blobs(directory, options).each do |blob|
            hash = File.parse blob
            hash['directory'] = directory
            files << hash
          end
          load files
        end

        def get(key, options = {})
          requires :directory
          blob_meta, content = service.get_blob_content(directory, key, options = {})
          new(key: key, body: content, service: service)
        end

        def head(key, options = { timeout: 3 })
          get(key, options).get_properties
        rescue Azure::Core::Http::HTTPError => ex
          if ex.status_code.between?(400, 499)
            nil
          else
            raise ex
          end
        end
      end
    end
  end
end
