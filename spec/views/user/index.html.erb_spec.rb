require 'rails_helper'

RSpec.describe "users/index.html.erb", type: :view do
  let(:user) { create(:user) }  # Assuming you have a factory for the User model
  let(:skin) { create(:skin, user: user) }  # Assuming you have a factory for the Skin model
  let(:achievements) { ['Achievement 1', 'Achievement 2'] }
  let(:other_user) { create(:user, username: 'other_user') }

  before do
    # Simulate the user being logged in
    sign_in user
    assign(:achievements, achievements)
    assign(:users, [user, other_user])
  end

  context "when the user has a profile picture" do
    before do
      user.profile_picture.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'image.png')), filename: 'image.png', content_type: 'image/png')
      render
    end

    it "displays the user's profile picture" do
      expect(rendered).to have_css("img.user-avatar")
    end

    it "displays the username with golden-text" do
      expect(rendered).to have_css("h1.golden-text", text: user.username)
    end
  end

  context "when the user does not have a profile picture" do
    before do
      render
    end

    it "displays 'No avatar uploaded' message" do
      expect(rendered).to include("No avatar uploaded.")
    end
  end

  context "when the user has a current skin" do
    before do
      user.update(current_skin: skin)
      skin.image.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'image.png')), filename: 'image.png', content_type: 'image/png')
      render
    end

    it "displays the user's skin image" do
      expect(rendered).to have_css("img.user-skin-image")
    end

    it "displays the skin's archetype" do
      expect(rendered).to include(skin.archetype)
    end

    it "displays the skin's stats correctly" do
      expect(rendered).to include(skin.health.to_s)
      expect(rendered).to include(skin.attack.to_s)
    end
  end

  context "when the user does not have a current skin" do
    before do
      render
    end

    it "displays 'No active skin selected' message" do
      expect(rendered).to include("No active skin selected. Please select a skin in your inventory.")
    end
  end

  context "when there are achievements" do
    before do
      render
    end

    it "displays the achievements list" do
      achievements.each do |achievement|
        expect(rendered).to include(achievement)
      end
    end
  end

  context "when there are no achievements" do
    before do
      assign(:achievements, [])
      render
    end

    it "displays 'No achievements yet' message" do
      expect(rendered).to include("No achievements yet.")
    end
  end

  context "when there is a user search form" do
    before do
      render
    end

    it "displays the search form" do
      expect(rendered).to have_css('form.search-form')
      expect(rendered).to have_field('search')
    end

    it "displays the 'Search' button" do
      expect(rendered).to have_button('Search')
    end
  end

  context "when displaying users in the search results" do
    before do
      render
    end

    it "displays the other user in the search results" do
      expect(rendered).to include(other_user.username)
    end

    it "shows the correct buttons (Add Friend or Remove Friend)" do
      if user.friends.include?(other_user)
        expect(rendered).to have_button('Remove Friend')
      else
        expect(rendered).to have_button('Add Friend')
      end
    end
  end

  context "when displaying the friends list" do
    let!(:friend) { create(:user, username: 'friend_user') }

    before do
      user.friends << friend
      render
    end

    it "displays the friends list" do
      expect(rendered).to include(friend.username)
    end

    it "shows a 'Chat' button for each friend" do
      expect(rendered).to have_button('Chat')
    end

    it "shows a 'Remove Friend' button for each friend" do
      expect(rendered).to have_button('Remove Friend')
    end
  end

  context "when the user has no friends" do
    before do
      user.friends.clear
      render
    end

    it "displays 'You have no friends yet.'" do
      expect(rendered).to include("You have no friends yet.")
    end
  end

  context "when the user is logged out" do
    before do
      sign_out user
      render
    end

    it "does not display any user-related content" do
      expect(rendered).not_to include(user.username)
      expect(rendered).not_to have_css('img.user-avatar')
    end
  end
end
