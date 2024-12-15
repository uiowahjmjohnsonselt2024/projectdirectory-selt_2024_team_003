require 'rails_helper'

RSpec.describe "inventory/index.html.erb", type: :view do
  let(:user) { create(:user) }
  let(:skin) { create(:skin, user: user) }
  let(:consumable) { create(:consumable, user: user) }
  let(:weapon) { create(:weapon, user: user) }

  before do
    sign_in user  # Ensure user is signed in
    assign(:skins, [skin])
    assign(:consumables, [consumable])
    assign(:weapons, [weapon])
  end

  context 'when viewing the avatars tab' do
    before do
      render template: 'inventory/index.html.erb', locals: { tab: 'avatars' }
    end

    it 'displays the avatars section correctly' do
      expect(rendered).to have_css('.skins-container')
      expect(rendered).to have_content('Archetype: ' + skin.archetype)
      expect(rendered).to have_selector('img.skin-image')
      expect(rendered).to have_link('Equip')
      expect(rendered).to have_link('Remove')
    end

    it 'marks the avatars tab as active' do
      expect(rendered).to have_css('.tabs-navigation .active', text: 'Avatars')
    end
  end

  context 'when viewing the consumables tab' do
    before do
      render template: 'inventory/index.html.erb', locals: { tab: 'consumables' }
    end

    it 'displays the consumables section correctly' do
      expect(rendered).to have_css('.consumables-container')
      expect(rendered).to have_content(consumable.name)
      expect(rendered).to have_content('Quantity: ' + consumable.quantity.to_s)
      expect(rendered).to have_selector('img.consable-image')
    end

    it 'displays a message when no consumables are present' do
      assign(:consumables, [])
      render template: 'inventory/index.html.erb', locals: { tab: 'consumables' }
      expect(rendered).to have_content('You have no consumables.')
    end

    it 'marks the consumables tab as active' do
      expect(rendered).to have_css('.tabs-navigation .active', text: 'Consumables')
    end
  end

  context 'when viewing the weapons tab' do
    before do
      render template: 'inventory/index.html.erb', locals: { tab: 'weapons' }
    end

    it 'displays the weapons section correctly' do
      expect(rendered).to have_css('.weapons-container')
      expect(rendered).to have_content(weapon.name)
      expect(rendered).to have_selector('img.weapon-image')
      expect(rendered).to have_link('Equip')
    end

    it 'displays a message when no weapons are present' do
      assign(:weapons, [])
      render template: 'inventory/index.html.erb', locals: { tab: 'weapons' }
      expect(rendered).to have_content('You have no weapons.')
    end

    it 'marks the weapons tab as active' do
      expect(rendered).to have_css('.tabs-navigation .active', text: 'Weapons')
    end
  end

  context 'when viewing the page with no active tab' do
    before do
      render template: 'inventory/index.html.erb', locals: { tab: nil }
    end

    it 'defaults to the avatars tab being active' do
      expect(rendered).to have_css('.tabs-navigation .active', text: 'Avatars')
    end
  end

  context 'modals' do
    it 'displays the skin stats modal' do
      render template: 'inventory/index.html.erb'
      expect(rendered).to have_css('#skin-stats-modal')
      expect(rendered).to have_content('Skin Stats')
    end

    it 'displays the weapon stats modal' do
      render template: 'inventory/index.html.erb'
      expect(rendered).to have_css('#weapon-stats-modal')
      expect(rendered).to have_content('Weapon Stats')
    end

    it 'displays the consumable stats modal' do
      render template: 'inventory/index.html.erb'
      expect(rendered).to have_css('#consumable-stats-modal')
      expect(rendered).to have_content('Consumable Details')
    end
  end
end
