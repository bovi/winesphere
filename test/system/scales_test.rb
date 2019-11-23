require "application_system_test_case"

class ScalesTest < ApplicationSystemTestCase
  setup do
    @scale = scales(:one)
  end

  test "visiting the index" do
    visit scales_url
    assert_selector "h1", text: "Scales"
  end

  test "creating a Scale" do
    visit scales_url
    click_on "New Scale"

    fill_in "Booth", with: @scale.booth_id
    fill_in "Name", with: @scale.name
    click_on "Create Scale"

    assert_text "Scale was successfully created"
    click_on "Back"
  end

  test "updating a Scale" do
    visit scales_url
    click_on "Edit", match: :first

    fill_in "Booth", with: @scale.booth_id
    fill_in "Name", with: @scale.name
    click_on "Update Scale"

    assert_text "Scale was successfully updated"
    click_on "Back"
  end

  test "destroying a Scale" do
    visit scales_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Scale was successfully destroyed"
  end
end
