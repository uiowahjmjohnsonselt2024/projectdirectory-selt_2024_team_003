require 'rails_helper'

RSpec.describe Skin, type: :model do
  let(:user) { create(:user) }

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_one_attached(:image) }
  end

  describe "validations" do
    context "when image is attached" do
      it "is valid" do
        # Create a Skin with an attached image
        skin = build(:skin, user: user)
        expect(skin).to be_valid
      end
    end

    context "when image is not attached" do
      it "is not valid and adds an error for image" do
        skin = build(:skin, user: user)
        # Remove the attachment that the factory might add
        skin.image.detach if skin.image.attached?

        expect(skin).not_to be_valid
        expect(skin.errors[:image]).to include("must be attached")
      end
    end
  end
end
