require 'rails_helper'

RSpec.describe Article, type: :model do
  describe 'associations' do
    it { should belong_to(:author).class_name('Author') }
    it { should have_many(:comments) }
    it { should have_and_belong_to_many(:tags) }
  end
end
