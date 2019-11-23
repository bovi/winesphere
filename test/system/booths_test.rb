require "application_system_test_case"

class BoothsTest < ApplicationSystemTestCase
  setup do
    @booth = booths(:one)
  end

  test "visiting the index" do
    visit booths_url
    assert_selector "h1", text: "Booths"
  end

  test "creating a Booth" do
    visit booths_url
    click_on "New Booth"

    fill_in "Name", with: @booth.name
    click_on "Create Booth"

    assert_text "Booth was successfully created"
    click_on "Back"
  end

  test "updating a Booth" do
    visit booths_url
    click_on "Edit", match: :first

    fill_in "Name", with: @booth.name
    click_on "Update Booth"

    assert_text "Booth was successfully updated"
    click_on "Back"
  end

  test "destroying a Booth" do
    visit booths_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Booth was successfully destroyed"
  end
end
