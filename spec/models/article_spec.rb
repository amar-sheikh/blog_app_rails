require 'rails_helper'

RSpec.describe Article, type: :model do
  describe 'associations' do
    it { should belong_to(:author).class_name('Author') }
    it { should have_many(:comments) }
    it { should have_and_belong_to_many(:tags) }
  end

  describe 'scopes' do
    describe 'published' do
      subject(:published_articles) { Article.published }

      let(:published_article) { create(:article, published: true, published_at: 7.days.ago + 1.minute ) }
      let(:un_published_article) { create(:article, published: false) }

      it 'returns published articles only' do
        expect(published_articles).to include published_article
        expect(published_articles).not_to include un_published_article
      end

      context 'when no published article exists' do
        let(:published) { nil }

        it 'returns empty array' do
          expect(published_articles).to be_empty
        end
      end
    end

    describe 'un_published' do
      subject(:un_published_articles) { Article.un_published }

      let(:published_article) { create(:article, published: true, published_at: 7.days.ago + 1.minute ) }
      let(:un_published_article) { create(:article, published: false) }

      it 'returns un published articles only' do
        expect(un_published_articles).to include un_published_article
        expect(un_published_articles).not_to include published_article
      end

      context 'when no un published article exists' do
        let(:un_published) { nil }

        it 'returns empty array' do
          expect(un_published_articles).to be_empty
        end
      end
    end

    describe 'recent' do
      subject(:recent_articles) { Article.recent }

      before { Timecop.freeze('2025-02-1 10:30:00') }
      after { Timecop.return }

      context 'when days not passed' do
        let(:recent_article) { create(:article, published: true, published_at: 7.days.ago + 1.minute ) }
        let(:non_recent_article) { create(:article, published: true, published_at: 7.days.ago - 1.minutes ) }

        it 'returns recent articles only' do
          expect(recent_articles).to include recent_article
          expect(recent_articles).not_to include non_recent_article
        end

        context 'when no recent article exists' do
          let(:recent_article) { nil }

          it 'returns empty array' do
            expect(recent_articles).to be_empty
          end
        end
      end

      context 'when days are passed' do
        subject(:recent_articles) { Article.recent(days) }

        let(:days) { 4 }
        let(:recent_article) { create(:article, published: true, published_at: 4.days.ago + 1.minute ) }
        let(:non_recent_article) { create(:article, published: true, published_at: 4.days.ago - 1.minutes ) }

        it 'returns recent articles only' do
          expect(recent_articles).to include recent_article
          expect(recent_articles).not_to include non_recent_article
        end

        context 'when no recent article exists with in days' do
          let(:days) { 3 }

          it 'returns empty array' do
            expect(recent_articles).to be_empty
          end
        end

        context 'when invalid days are passed' do
          let(:days) { '4' }

          it { expect{ recent_articles }.to raise_error(NoMethodError, /undefined method `days' for "4":String/) }
        end

        context 'when days are nil' do
          let(:days) { nil }

          it { expect{ recent_articles }.to raise_error(NoMethodError, /undefined method `days' for nil:NilClass/) }
        end
      end
    end

    describe 'search' do
      subject(:search_articles) { Article.search(search) }

      let(:search) { 'hello' }

      let(:matching_article_1) { create(:article, title: 'hello 123', content: 'content') }
      let(:matching_article_2) { create(:article, title: 'article 1', content: 'hello content') }
      let(:non_matching_article) { create(:article, title: 'article 2', content: 'content') }

      it 'returns matching articles' do
        expect(search_articles).to include matching_article_1
        expect(search_articles).to include matching_article_2
        expect(search_articles).not_to include non_matching_article
      end

      context 'when no matching result found' do
        let(:search) { 'un matching text' }

        it 'returns empty array' do
          expect(search_articles).to be_empty
        end
      end

      context 'when search is nil' do
        let(:search) { nil }

        it { expect{ search_articles }.to raise_error(NoMethodError, /undefined method `downcase' for nil:NilClass/) }
      end

      context 'when search is blank' do
        let(:search) { '' }

        it 'returns all articles' do
          expect(search_articles).to include matching_article_1
          expect(search_articles).to include matching_article_2
          expect(search_articles).to include non_matching_article
        end
      end
    end

    describe 'by_authors' do
      subject(:by_authors) { Article.by_authors(author_ids) }

      let(:author1) { create(:author) }
      let(:author2) { create(:author) }
      let(:author1_article) { create(:article, author: author1) }
      let(:author2_article) { create(:article, author: author2) }
      let(:author_ids) { [ author1.id ] }

      it 'returns article of matching authors only' do
        expect(by_authors).to include author1_article
        expect(by_authors).not_to include author2_article
      end

      context 'when no article found for authors' do
        let(:author1_article) { nil }

        it 'returns empty array' do
          expect(by_authors).to be_empty
        end
      end

      context 'when author ids are blank' do
        let(:author_ids) { [] }

        it 'returns empty array' do
          expect(by_authors).to be_empty
        end
      end

      context 'when author ids are invalid' do
        let(:author_ids) { [ 'invalid' ] }

        it 'returns empty array' do
          expect(by_authors).to be_empty
        end
      end

      context 'when author ids are in string' do
        let(:author_ids) { [ author1.id.to_s ] }

        it 'returns empty array' do
          expect(by_authors).to be_empty
        end
      end
    end

    describe 'tagged' do
      subject(:tagged_articles) { Article.tagged }

      let!(:tag1) { create(:tag) }
      let!(:tag2) { create(:tag) }
      let!(:non_tagged_article) { create(:article ) }
      let!(:tag1_article) { create(:article, tag_ids:[tag1.id] ) }
      let!(:tag2_article) { create(:article, tag_ids:[tag2.id] ) }
      let!(:both_tag_article) { create(:article, tag_ids:[tag1.id, tag2.id] ) }

      context 'when tag ids not passed' do
        it 'returns tagged articles' do
          expect(tagged_articles).to include tag1_article
          expect(tagged_articles).to include tag2_article
          expect(tagged_articles).to include both_tag_article
          expect(tagged_articles).not_to include non_tagged_article
        end
      end

      context 'when tag ids passed' do
        subject(:tagged_articles) { Article.tagged(tag_ids) }

        let(:tag_ids) { [ tag1.id ] }

        it 'returns matching tag articles' do
          expect(tagged_articles).to include tag1_article
          expect(tagged_articles).to include both_tag_article
          expect(tagged_articles).not_to include tag2_article
          expect(tagged_articles).not_to include non_tagged_article
        end

        context 'when no article found for matching tags' do
          let(:tag1_article) { nil }
          let(:both_tag_article) { nil }

          it 'returns empty array' do
            expect(tagged_articles).to be_empty
          end
        end

        context 'when tag ids are blank' do
          let(:tag_ids) { [] }

          it 'returns tagged articles' do
            expect(tagged_articles).to include tag1_article
            expect(tagged_articles).to include tag2_article
            expect(tagged_articles).to include both_tag_article
            expect(tagged_articles).not_to include non_tagged_article
          end
        end

        context 'when tag ids are invalid' do
          let(:tag_ids) { [ 'invalid' ] }

          it 'returns empty array' do
            expect(tagged_articles).to be_empty
          end
        end

        context 'when tag ids are in string' do
          let(:tag_ids) { [ tag1.id.to_s ] }

          it 'returns matching tag articles' do
            expect(tagged_articles).to include tag1_article
            expect(tagged_articles).to include both_tag_article
            expect(tagged_articles).not_to include tag2_article
            expect(tagged_articles).not_to include non_tagged_article
          end
        end
      end
    end

    describe 'commented' do
      subject(:commented_articles) { Article.commented }

      let!(:non_commented_article) { create(:article ) }
      let!(:article_with_1_comment) { create(:article, :commented, comments_count: 1 ) }
      let!(:article_with_2_comments) { create(:article, :commented, comments_count: 2 ) }

      context 'when comment count not passed' do
        it 'returns commented articles' do
          expect(commented_articles).to include article_with_1_comment
          expect(commented_articles).to include article_with_2_comments
          expect(commented_articles).not_to include non_commented_article
        end
      end

      context 'when comment count passed' do
        subject(:commented_articles) { Article.commented(comments_count) }

        let(:comments_count) { 2 }

        it 'returns articles with at least the specified number of comments' do
          expect(commented_articles).to include article_with_2_comments
          expect(commented_articles).not_to include article_with_1_comment
          expect(commented_articles).not_to include non_commented_article
        end

        context 'when comment count in string' do
          let(:comments_count) { '2' }

          it 'returns empty array' do
            expect(commented_articles).to be_empty
          end
        end

        context 'when invalid comment count passed' do
          let(:comments_count) { 'invalid' }

          it 'returns empty array' do
            expect(commented_articles).to be_empty
          end
        end

        context 'when comment count is nil' do
          let(:comments_count) { nil }

          it 'returns empty array' do
            expect(commented_articles).to be_empty
          end
        end
      end
    end

    describe 'hot' do
      subject(:hot_articles) { Article.hot }

      let!(:tag1) { create(:tag) }
      let!(:tag2) { create(:tag) }
      let!(:non_hot_article) { create(:article, published: true, published_at: 7.days.ago + 1.minute ) }
      let!(:hot_article_with_tag1) { create(:article, :commented, comments_count: 1, tag_ids: [tag1.id], published: true, published_at: 7.days.ago + 1.minute ) }
      let!(:hot_article_with_tag2) { create(:article, :commented, comments_count: 1, tag_ids: [tag2.id], published: true, published_at: 4.days.ago + 1.minute ) }
      let!(:hot_article_with_both_tags) { create(:article, :commented, comments_count: 1, tag_ids: [tag1.id, tag2.id], published: true, published_at: 4.days.ago + 1.minute ) }

      context 'when no argument passed' do
        it 'returns hot articles' do
          expect(hot_articles).to include hot_article_with_tag1
          expect(hot_articles).to include hot_article_with_tag2
          expect(hot_articles).to include hot_article_with_both_tags
          expect(hot_articles).not_to include non_hot_article
        end

        context 'when no hot article exists' do
          let(:hot_article_with_tag1) { nil }
          let(:hot_article_with_tag2) { nil }
          let(:hot_article_with_both_tags) { nil }

          it 'returns empty array' do
            expect(hot_articles).to be_empty
          end
        end
      end

      context 'when days are passed' do
        subject(:hot_articles) { Article.hot(days) }

        let(:days) { 4 }

        it 'returns hot articles within days' do
          expect(hot_articles).to include hot_article_with_tag2
          expect(hot_articles).to include hot_article_with_both_tags
          expect(hot_articles).not_to include hot_article_with_tag1
          expect(hot_articles).not_to include non_hot_article
        end

        context 'when no hot article exists with in days' do
          let(:days) { 3 }

          it 'returns empty array' do
            expect(hot_articles).to be_empty
          end
        end

        context 'when invalid days are passed' do
          let(:days) { '4' }

          it { expect{ hot_articles }.to raise_error(NoMethodError, /undefined method `days' for "4":String/) }
        end

        context 'when days are nil' do
          let(:days) { nil }

          it { expect{ hot_articles }.to raise_error(NoMethodError, /undefined method `days' for nil:NilClass/) }
        end
      end

      context 'when tag ids are also passed' do
        subject(:hot_articles) { Article.hot(days, tag_ids) }

        let(:tag_ids) { [ tag1.id ] }
        let(:days) { 4 }

        it 'returns matching hot articles with in days' do
          expect(hot_articles).to include hot_article_with_both_tags
          expect(hot_articles).not_to include hot_article_with_tag1
          expect(hot_articles).not_to include hot_article_with_tag2
          expect(hot_articles).not_to include non_hot_article
        end

        context 'when no article found for matching tags' do
          let(:hot_article_with_tag1) { nil }
          let(:hot_article_with_both_tags) { nil }

          it 'returns empty array' do
            expect(hot_articles).to be_empty
          end
        end

        context 'when tag ids are blank' do
          let(:tag_ids) { [] }

          it 'returns all hot articles within days' do
            expect(hot_articles).to include hot_article_with_tag2
            expect(hot_articles).to include hot_article_with_both_tags
            expect(hot_articles).not_to include hot_article_with_tag1
            expect(hot_articles).not_to include non_hot_article
          end
        end

        context 'when tag ids are invalid' do
          let(:tag_ids) { [ 'invalid' ] }

          it 'returns empty array' do
            expect(hot_articles).to be_empty
          end
        end

        context 'when tag ids are in string' do
          let(:tag_ids) { [ tag1.id.to_s ] }

          it 'returns all matching hot articles within days' do
            expect(hot_articles).to include hot_article_with_both_tags
            expect(hot_articles).not_to include hot_article_with_tag2
            expect(hot_articles).not_to include hot_article_with_tag1
            expect(hot_articles).not_to include non_hot_article
          end
        end
      end
    end

    describe 'trending' do
      subject(:trending_articles) { Article.trending }

      let!(:tag1) { create(:tag) }
      let!(:tag2) { create(:tag) }
      let!(:non_trending_article) { create(:article, published: true, published_at: 7.days.ago + 1.minute ) }
      let!(:trending_article_with_tag1) { create(:article, :commented, comments_count: 5, tag_ids: [tag1.id], published: true, published_at: 3.days.ago + 1.minute ) }
      let!(:trending_article_with_tag2) { create(:article, :commented, comments_count: 6, tag_ids: [tag2.id], published: true, published_at: 2.days.ago + 2.minute ) }
      let!(:trending_article_with_both_tags) { create(:article, :commented, comments_count: 7, tag_ids: [tag1.id, tag2.id], published: true, published_at: 2.days.ago + 1.minute ) }

      context 'when no argument passed' do
        it 'returns trending articles' do
          expect(trending_articles).to include trending_article_with_tag1
          expect(trending_articles).to include trending_article_with_tag2
          expect(trending_articles).to include trending_article_with_both_tags
          expect(trending_articles).not_to include non_trending_article
        end

        context 'when no trending article exists' do
          let(:trending_article_with_tag1) { nil }
          let(:trending_article_with_tag2) { nil }
          let(:trending_article_with_both_tags) { nil }

          it 'returns empty array' do
            expect(trending_articles).to be_empty
          end
        end
      end

      context 'when comments count passed' do
        subject(:trending_articles) { Article.trending(comments_count) }

        let(:comments_count) { 6 }

        it 'returns trending articles with at least the specified number of comments' do
          expect(trending_articles).to include trending_article_with_tag2
          expect(trending_articles).to include trending_article_with_both_tags
          expect(trending_articles).not_to include trending_article_with_tag1
          expect(trending_articles).not_to include non_trending_article
        end

        context 'when no trending article having comment count equal or more than specified value' do
          let(:comments_count) { 8 }

          it 'returns empty array' do
            expect(trending_articles).to be_empty
          end
        end

        context 'when count passed as string' do
          let(:comments_count) { '7' }

          it 'returns empty array' do
            expect(trending_articles).to be_empty
          end
        end

        context 'when invalid count passed' do
          let(:comments_count) { 'invalid' }

          it 'returns empty array' do
            expect(trending_articles).to be_empty
          end
        end

        context 'when count are nil' do
          let(:comments_count) { nil }

          it 'returns empty array' do
            expect(trending_articles).to be_empty
          end
        end
      end

      context 'when days are also passed' do
        subject(:trending_articles) { Article.trending(comments_count, days_count = days) }

        let(:comments_count) { 6 }
        let(:days) { 2 }

        it 'returns trending articles within days' do
          expect(trending_articles).to include trending_article_with_tag2
          expect(trending_articles).to include trending_article_with_both_tags
          expect(trending_articles).not_to include trending_article_with_tag1
          expect(trending_articles).not_to include non_trending_article
        end

        context 'when no trending article exists with in days' do
          let(:days) { 1 }

          it 'returns empty array' do
            expect(trending_articles).to be_empty
          end
        end

        context 'when invalid days are passed' do
          let(:days) { '2' }

          it { expect{ trending_articles }.to raise_error(NoMethodError, /undefined method `days' for "2":String/) }
        end

        context 'when days are nil' do
          let(:days) { nil }

          it { expect{ trending_articles }.to raise_error(NoMethodError, /undefined method `days' for nil:NilClass/) }
        end
      end

      context 'when tag ids are also passed' do
        subject(:trending_articles) { Article.trending(comments_count, days, tag_ids) }

        let(:tag_ids) { [ tag1.id ] }
        let(:days) { 2 }
        let(:comments_count) { 6 }

        it 'returns matching trending articles with in days' do
          expect(trending_articles).to include trending_article_with_both_tags
          expect(trending_articles).not_to include trending_article_with_tag1
          expect(trending_articles).not_to include trending_article_with_tag2
          expect(trending_articles).not_to include non_trending_article
        end

        context 'when no article found for matching tags' do
          let(:trending_article_with_tag1) { nil }
          let(:trending_article_with_both_tags) { nil }

          it 'returns empty array' do
            expect(trending_articles).to be_empty
          end
        end

        context 'when tag ids are blank' do
          let(:tag_ids) { [] }

          it 'returns trending articles within days' do
            expect(trending_articles).to include trending_article_with_tag2
            expect(trending_articles).to include trending_article_with_both_tags
            expect(trending_articles).not_to include trending_article_with_tag1
            expect(trending_articles).not_to include non_trending_article
          end
        end

        context 'when tag ids are invalid' do
          let(:tag_ids) { [ 'invalid' ] }

          it 'returns empty array' do
            expect(trending_articles).to be_empty
          end
        end

        context 'when tag ids are in string' do
          let(:tag_ids) { [ tag1.id.to_s ] }

          it 'returns matching trending articles within days' do
            expect(trending_articles).to include trending_article_with_both_tags
            expect(trending_articles).not_to include trending_article_with_tag2
            expect(trending_articles).not_to include trending_article_with_tag1
            expect(trending_articles).not_to include non_trending_article
          end
        end
      end
    end
  end
end
