require 'test_helper'

class SpiderTasksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get spider_tasks_index_url
    assert_response :success
  end

end
