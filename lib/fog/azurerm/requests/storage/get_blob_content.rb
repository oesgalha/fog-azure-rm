module Fog
  module Storage
    class AzureRM
      # This class provides the actual implemention for service calls.
      class Real
        def get_blob_content(directory, key, options = {})
          @blob_client.get_blob(directory, key, options)
        end
      end
      # This class provides the mock implementation for unit tests.
      class Mock
        def get_blob_content(directory, key, _options = {})
          Fog::Logger.debug 'File downloaded successfully.'
          {
            'name' => blob_name,
            'metadata' => {},
            'properties' =>
              {
                'last_modified' => 'Thu, 28 Jul 2016 06:53:05 GMT',
                'etag' => '0x8D3B6B3D353FFCA',
                'lease_status' => 'unlocked',
                'lease_state' => 'available',
                'lease_duration' => nil,
                'content_length' => 4_194_304,
                'content_type' => 'application/atom+xml; charset=utf-8',
                'content_encoding' => 'ASCII-8BIT',
                'content_language' => nil,
                'content_disposition' => nil,
                'content_md5' => 'tXAohIyxuu/t94Lp/ujeRw==',
                'cache_control' => nil,
                'blob_type' => 'BlockBlob',
                'copy_id' => nil,
                'copy_status' => nil,
                'copy_source' => nil,
                'copy_progress' => nil,
                'copy_completion_time' => nil,
                'copy_status_description' => nil,
                'accept_ranges' => 0
              }
          }
        end
      end
    end
  end
end
