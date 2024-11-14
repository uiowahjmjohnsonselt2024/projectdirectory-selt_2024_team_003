require 'rails_helper'

RSpec.describe 'Grid Page', type: :feature do
  before do
    visit '/pages/grid' # Update the path if necessary
  end

  describe 'Page Layout' do
    it 'displays the left column with user stats' do
      expect(page).to have_selector('.left-column')
      expect(page).to have_selector('.profile')
      expect(page).to have_selector('.username-placeholder', text: 'Username')
      expect(page).to have_selector('.stats .stat', count: 3) # Checks for 3 stat items
    end

    it 'displays the middle grid with an 8x8 layout' do
      expect(page).to have_selector('.grid-container')
      expect(page).to have_selector('.grid-row', count: 8)
      within '.grid-container' do
        expect(page).to have_selector('.grid-square', count: 64) # 8x8 grid
      end
    end

    it 'displays the right column with the shop' do
      expect(page).to have_selector('.right-column')
      expect(page).to have_selector('.shop-header', text: 'Shop')
      expect(page).to have_selector('.shop-item', minimum: 1) # Ensures at least 1 shop item
    end

    it 'displays the chat section' do
      expect(page).to have_selector('.chat-section')
      expect(page).to have_selector('#chat-messages')
      expect(page).to have_selector('#chat-input')
      expect(page).to have_selector('#send-button')
    end
  end
end
