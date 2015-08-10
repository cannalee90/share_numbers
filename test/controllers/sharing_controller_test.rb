require 'test_helper'

class SharingControllerTest < ActionController::TestCase
  test "should get sendsms" do
    get :sendsms
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get select" do
    get :select
    assert_response :success
  end

end
