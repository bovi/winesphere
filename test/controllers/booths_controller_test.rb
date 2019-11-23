require 'test_helper'

class BoothsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @booth = booths(:one)
  end

  test "should get index" do
    get booths_url
    assert_response :success
  end

  test "should get new" do
    get new_booth_url
    assert_response :success
  end

  test "should create booth" do
    assert_difference('Booth.count') do
      post booths_url, params: { booth: { name: @booth.name } }
    end

    assert_redirected_to booth_url(Booth.last)
  end

  test "should show booth" do
    get booth_url(@booth)
    assert_response :success
  end

  test "should get edit" do
    get edit_booth_url(@booth)
    assert_response :success
  end

  test "should update booth" do
    patch booth_url(@booth), params: { booth: { name: @booth.name } }
    assert_redirected_to booth_url(@booth)
  end

  test "should destroy booth" do
    assert_difference('Booth.count', -1) do
      delete booth_url(@booth)
    end

    assert_redirected_to booths_url
  end
end
