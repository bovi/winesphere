require 'test_helper'

class ThermometersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @thermometer = thermometers(:one)
  end

  test "should get index" do
    get thermometers_url
    assert_response :success
  end

  test "should get new" do
    get new_thermometer_url
    assert_response :success
  end

  test "should create thermometer" do
    assert_difference('Thermometer.count') do
      post thermometers_url, params: { thermometer: { booth_id: @thermometer.booth_id, name: @thermometer.name } }
    end

    assert_redirected_to thermometer_url(Thermometer.last)
  end

  test "should show thermometer" do
    get thermometer_url(@thermometer)
    assert_response :success
  end

  test "should get edit" do
    get edit_thermometer_url(@thermometer)
    assert_response :success
  end

  test "should update thermometer" do
    patch thermometer_url(@thermometer), params: { thermometer: { booth_id: @thermometer.booth_id, name: @thermometer.name } }
    assert_redirected_to thermometer_url(@thermometer)
  end

  test "should destroy thermometer" do
    assert_difference('Thermometer.count', -1) do
      delete thermometer_url(@thermometer)
    end

    assert_redirected_to thermometers_url
  end
end
