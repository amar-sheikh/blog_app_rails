require 'rails_helper'

RSpec.describe Author, type: :model do
  describe 'associations' do
    it { should have_many(:articles).with_foreign_key(:author_id) }
  end
end
