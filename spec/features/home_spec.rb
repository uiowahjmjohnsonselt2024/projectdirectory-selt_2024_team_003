require 'rails_helper'

RSpec.feature 'Home Page', type: :feature do
  before do
    visit root_path  # Assuming this is the root path for your home page
  end

  scenario 'User sees the background video' do
    # Ensure the video tag is present
    expect(page).to have_css('video.background-video')

    # Ensure the video is set to autoplay, loop, muted, and playsinline
    video = find('video.background-video')
    expect(video['autoplay']).to eq('true')
    expect(video['loop']).to eq('true')
    expect(video['muted']).to eq('true')
    expect(video['playsinline']).to eq('true')
  end

  scenario 'User sees the welcome message' do
    # Ensure the welcome message is displayed
    expect(page).to have_content('Shards of the Grid!')
  end

  scenario 'User sees the login and create buttons' do
    # Ensure login and create buttons are present and clickable
    expect(page).to have_link('Login', href: login_button_path)
    expect(page).to have_link('Create', href: create_button_path)

    # Click the login button and verify the redirection (adjust as needed)
    click_link 'Login'
    expect(current_path).to eq(login_button_path)  # Adjust this path based on your app's routes

    # Navigate back to the home page
    visit root_path

    # Click the create button and verify the redirection (adjust as needed)
    click_link 'Create'
    expect(current_path).to eq(create_button_path)  # Adjust this path based on your app's routes
  end

  scenario 'User sees the how-to-play modal' do
    # Ensure the modal is hidden initially
    expect(page).to have_css('#how-to-play-modal.modal.hidden')

    # Click the How to Play button to show the modal
    click_button 'How to Play'

    # Ensure the modal is now visible
    expect(page).to have_css('#how-to-play-modal.modal:not(.hidden)')

    # Ensure the modal content is correct
    expect(page).to have_content('How to Play')
    expect(page).to have_content('Embark on an epic journey through the grid to collect powerful shards!')

    # Close the modal
    click_button 'Close'

  end

  scenario 'User sees the footer with the copyright text' do
    # Ensure the footer is present with the correct copyright text
    expect(page).to have_css('footer.footer')
    expect(page).to have_content('© 2024 Shards of the Grid. All rights reserved.')
  end
end
