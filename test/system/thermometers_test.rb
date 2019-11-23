require "application_system_test_case"

class ThermometersTest < ApplicationSystemTestCase
  setup do
    @thermometer = thermometers(:one)
  end

  test "visiting the index" do
    visit thermometers_url
    assert_selector "h1", text: "Thermometers"
  end

  test "creating a Thermometer" do
    visit thermometers_url
    click_on "New Thermometer"

    fill_in "Booth", with: @thermometer.booth_id
    fill_in "Name", with: @thermometer.name
    click_on "Create Thermometer"

    assert_text "Thermometer was successfully created"
    click_on "Back"
  end

  test "updating a Thermometer" do
    visit thermometers_url
    click_on "Edit", match: :first

    fill_in "Booth", with: @thermometer.booth_id
    fill_in "Name", with: @thermometer.name
    click_on "Update Thermometer"

    assert_text "Thermometer was successfully updated"
    click_on "Back"
  end

  test "destroying a Thermometer" do
    visit thermometers_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Thermometer was successfully destroyed"
  end
end
