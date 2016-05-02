require File.expand_path '../../test_helper', __dir__

# Test class for List Resource Groups Request
class TestListResourceGroups < Minitest::Test
  def setup
    @service = Fog::Resources::AzureRM.new(credentials)
    client = @service.instance_variable_get(:@rmc)
    @resource_groups = client.resource_groups
    @promise = Concurrent::Promise.execute do
    end
  end

  def test_list_resource_group_success
    response = ApiStub::Requests::Resources::ResourceGroup.list_resource_group_response
    @promise.stub :value!, response do
      @resource_groups.stub :list, @promise do
        assert_equal @service.list_resource_groups, response.body.value
      end
    end
  end

  def test_list_resource_group_failure
    response = -> { fail MsRestAzure::AzureOperationError.new(nil, nil, 'error' => { 'message' => 'mocked exception' }) }
    @promise.stub :value!, response do
      @resource_groups.stub :list, @promise do
        assert_raises(RuntimeError) { @service.list_resource_groups }
      end
    end
  end
end
