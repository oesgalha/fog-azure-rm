module Fog
  module Storage
    class AzureRM
      # This class is giving implementation of listing blobs.
      class Files < Fog::Collection
        model File
        attribute :directory

        def all(options = { metadata: true })
          files = []
          service.list_blobs(directory, options).each do |blob|
            hash = File.parse blob
            hash['directory'] = directory
            files << hash
          end
          load files
        end

        def get(directory, name)
          file = File.new(service: service)
          file.directory = directory
          file.key = name
          file
        end

        def head(name, options = { timeout: 3 })
          requires :directory
          File.new(service: service).tap do |file|
            file.key = name
            file.directory = directory.key
            file.get_properties
          end
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
