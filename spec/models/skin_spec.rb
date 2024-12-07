require 'rails_helper'

RSpec.describe Skin, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_one_attached(:image) }
  end
end
