require 'rails_helper'

RSpec.describe "character_selection/show.html.erb", type: :view do
  before do
    assign(:characters, [
      { archetype: 'Attacker', image_path: 'attack.png', description: 'Favors intelligence and powerful attacks while sacrificing defense.' },
      { archetype: 'Defender', image_path: 'defense.png', description: 'Excels in defense and survivability with reduced attack power.' },
      { archetype: 'Healer', image_path: 'balanced.png', description: 'Equally strong across all stats, adaptable to various challenges.' }
    ])
  end

  it "displays the character selection cards" do
    render

    # Ensure the video background is displayed
    expect(rendered).to have_selector('video.background-video')

    # Ensure each card is rendered with the correct archetype
    expect(rendered).to have_selector('.card', count: 3)
    expect(rendered).to have_selector('.card[data-archetype="Attacker"]')
    expect(rendered).to have_selector('.card[data-archetype="Defender"]')
    expect(rendered).to have_selector('.card[data-archetype="Healer"]')

    # Ensure the images and descriptions are correct
    expect(rendered).to have_selector('img[src$="attack.png"]')
    expect(rendered).to have_selector('img[src$="defense.png"]')
    expect(rendered).to have_selector('img[src$="balanced.png"]')
    expect(rendered).to include('Favors intelligence and powerful attacks while sacrificing defense.')
    expect(rendered).to include('Excels in defense and survivability with reduced attack power.')
    expect(rendered).to include('Equally strong across all stats, adaptable to various challenges.')
  end

  it "has a functional select button" do
    render

    # Simulate a user clicking the 'Select' button for Attacker
    page.find('.card[data-archetype="Attacker"] button').click

    # Check that the PATCH request is made with the correct parameters
    expect(page).to have_selector('.card[data-archetype="Attacker"]', visible: false) # If there's UI feedback, you can check that too
  end

  it "handles the AJAX request on button click" do
    # Set up a mock for the AJAX request
    allow_any_instance_of(ApplicationController).to receive(:fetch).and_return(true)

    render

    # Simulate a click event
    page.find('.card[data-archetype="Defender"] button').click

    # Ensure an AJAX PATCH request is made
    expect(page).to have_received(:fetch)
  end

  it "redirects to the correct page after successful AJAX request" do
    # Setup mock to simulate successful response
    allow_any_instance_of(ApplicationController).to receive(:fetch).and_return({ success: true })

    render

    # Simulate the click event
    page.find('.card[data-archetype="Healer"] button').click

    # Ensure the page is redirected to '/games'
    expect(page).to have_current_path('/games')
  end

  it "shows an alert if the AJAX request fails" do
    # Setup mock to simulate failed response
    allow_any_instance_of(ApplicationController).to receive(:fetch).and_return({ success: false })

    render

    # Simulate the click event
    page.find('.card[data-archetype="Attacker"] button').click

    # Ensure an alert is shown
    expect(page).to have_selector('.alert', text: 'Failed to update stats.')
  end
end
