RSpec.shared_examples 'a user profile' do
  let(:links)    { build_array(2, :link) }
  let(:is_group) { false }
  let(:user)     { Fabricate.build(:active_user, id: 123, is_group: is_group, links: links) }

  before :each do
    assign(:user, user)
    render
  end

  it 'shows the avatar' do
    expect(rendered).to have_css('.user-profile__avatar img')
  end

  it 'shows the username' do
    expect(rendered).to have_css('.user-profile__username', text: user.screen_name)
  end

  context 'when the user is an individual' do
    let(:is_group) { false }

    it 'shows the first name' do
      expect(rendered).to have_css('.user-profile__details-list__item--title', text: 'First name:')
      expect(rendered).to have_css('.user-profile__details-list__item--value', text: user.first_name)
    end

    it 'shows the last name' do
      expect(rendered).to have_css('.user-profile__details-list__item--title', text: 'Last name:')
      expect(rendered).to have_css('.user-profile__details-list__item--value', text: user.last_name)
    end

    it 'does not show the group name' do
      expect(rendered).not_to have_css('.user-profile__details-list__item--title', text: 'Group name:')
    end
  end

  context 'when the user is a group' do
    let(:is_group) { true }

    it 'does not show the first name' do
      expect(rendered).not_to have_css('.user-profile__details-list__item--title', text: 'First name:')
    end

    it 'does not show the last name' do
      expect(rendered).not_to have_css('.user-profile__details-list__item--title', text: 'Last name:')
    end

    it 'shows the group name' do
      expect(rendered).to have_css('.user-profile__details-list__item--title', text: 'Group name:')
      expect(rendered).to have_css('.user-profile__details-list__item--value', text: user.first_name)
    end
  end

  it 'shows the description' do
    expect(rendered).to have_css('.user-profile__details-list__item--title', text: 'Bio:')
    expect(rendered).to have_css('.user-profile__details-list__item--value', text: user.description)
  end

  it 'shows the email' do
    expect(rendered).to have_css('.user-profile__details-list__item--title', text: 'Email:')
    expect(rendered).to have_css('.user-profile__details-list__item--value', text: user.email)
  end

  context "when the user has no links" do
    let(:links) { [] }

    it "does not display the requested user's links" do
      expect(rendered).not_to have_css('p.link')
      expect(rendered).not_to have_css('p.link a')
    end
  end

  context "when the user has links" do
    let(:links) { build_array(2, :link) }

    it "displays the requested user's links" do
      links.each do |link|
        expect(rendered).to have_css("p.link a[href=\"#{link.url}\"]", text: link.name, count: 1)
      end
    end
  end
end
