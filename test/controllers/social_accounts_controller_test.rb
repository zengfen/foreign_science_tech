require 'test_helper'

class SocialAccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get social_accounts_index_url
    assert_response :success
  end

end
