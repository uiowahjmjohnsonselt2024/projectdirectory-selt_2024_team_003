require 'rails_helper'
require 'ostruct'

RSpec.describe "chats/show.html.erb", type: :view do
  before do
    # Mock the current user
    @current_user = User.create!(username: "TestUser", email: "testuser@example.com", password: "password123")

    view.singleton_class.class_eval do
        def current_user
          User.new(username: "Test User")
        end
    end

    allow(view).to receive(:current_user).and_return(@current_user)

    # Mock the friend user
    @friend = User.create!(username: "FriendUser", email: "frienduser@example.com", password: "password123")

    # Mock the messages
    @messages = [
      OpenStruct.new(user: @current_user, content: "Hello, Friend!", read: true),
      OpenStruct.new(user: @friend, content: "Hi, TestUser!", read: false)
    ]

    assign(:friend, @friend)
    assign(:messages, @messages)
    assign(:new_message, Message.new)
  end

  it "renders the Back to Account button" do
    render
    expect(rendered).to have_link("Back to Account", href: account_path, class: "back-to-account-button")
  end

  it "renders the chat header with friend's username" do
    render
    expect(rendered).to have_selector("h2", text: "Chat with FriendUser")
  end

  it "renders all messages with proper CSS classes" do
    render
    expect(rendered).to have_selector(".message.sent", text: "TestUser: Hello, Friend!")
    expect(rendered).to have_selector(".message.received", text: "FriendUser: Hi, TestUser!")
    expect(rendered).to have_selector(".read-receipt", text: "(Read)")
  end

  it "renders the message input form" do
    render
    expect(rendered).to have_selector("form[action='#{send_message_path(friend_id: @friend.id)}']")
    expect(rendered).to have_selector("textarea#message-input[placeholder='Type your message...']")
    expect(rendered).to have_selector("input[type='submit'][value='Send']")
  end

  it "renders the Refresh button" do
    render
    expect(rendered).to have_selector("button.refresh-button", text: "Refresh")
  end
end