module Fog
  module Storage
    class AzureRM
      # This class provides the actual implemention for service calls.
      class Real
        def upload_block_blob_from_str(directory, key, str, options = {})
          if str.nil?
            raise "Attempt to write an empty blob"
          elsif str.bytesize <= SINGLE_BLOB_PUT_THRESHOLD
            @blob_client.create_block_blob(directory, key, str, options)
          else
            blocks = []
            StringIO.new(str).tap do |io|
              while (read_bytes = io.read(BLOCK_SIZE))
                Base64.strict_encode64(random_string(32)).tap do |block_id|
                  @blob_client.put_blob_block(directory, key, block_id, read_bytes, options)
                  blocks << [block_id]
                end
              end
            end
            @blob_client.commit_blob_blocks(directory, key, blocks, options)
          end
        rescue IOError => ex
          raise "Exception in reading the blob: #{ex.inspect}"
        rescue Azure::Core::Http::HTTPError => ex
          raise "Exception in uploading the blob: #{ex.inspect}"
        end
      end
      # This class provides the mock implementation for unit tests.
      class Mock
        def upload_block_blob_from_file(_dir, key, _str, _options = {})
          Fog::Logger.debug 'Blob created successfully.'
          {
            'name' => key,
            'properties' =>
              {
                'last_modified' => 'Thu, 28 Jul 2016 06:53:05 GMT',
                'etag' => '0x8D3B6B3D353FFCA',
                'content_md5' => 'tXAohIyxuu/t94Lp/ujeRw=='
              }
          }
        end
      end
    end
  end
end
