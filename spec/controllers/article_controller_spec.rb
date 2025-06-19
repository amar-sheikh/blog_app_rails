require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  describe '#index' do
    let!(:un_published_article) do
      create(
        :article,
        published: false,
        author: author1,
        tag_ids: [ tag1.id ],
        title:'non published title',
        content: 'non published content by author1, having tag1'
      )
    end
    let!(:published_article_1) do
      create(
        :article,
        published: true,
        published_at: 7.days.ago - 1.minutes,
        author: author1,
        title:'non recent published title',
        content: 'non recent published content by author1, having no tag'
      )
    end
    let!(:published_article_2) do
      create(
        :article,
        published: true,
        published_at: 7.days.ago - 2.minutes,
        author: author2,
        tag_ids: [ tag2.id ],
        title:'non recent published title',
        content: 'non recent published content by author2, having tag2'
      )
    end
    let!(:recent_article_1) do
      create(
        :article,
        :commented,
        comments_count: 1,
        published: true,
        published_at: 7.days.ago + 1.minute,
        author: author1,
        tag_ids: [ tag1.id, tag2.id ],
        title:'recently published title',
        content: 'recently published content by author1, having tag1 and tag2, and 1 comment'
      )
    end
    let!(:recent_article_2) do
      create(
        :article,
        published: true,
        published_at: 4.days.ago + 1.minute,
        tag_ids: [ tag1.id ],
        author: author2, title:'recently published title',
        content: 'recently published content by author2, having tag1'
      )
    end
    let!(:trending_article_1) do
      create(
        :article,
        :commented,
        comments_count: 5,
        published: true,
        published_at: 3.days.ago + 1.minute,
        author: author1,
        tag_ids: [ tag1.id ],
        title:'recently published title',
        content: 'recently published content by author1, having tag1, and 5 comments'
      )
    end
    let!(:trending_article_2) do
      create(
        :article,
        :commented,
        comments_count: 6,
        published: true,
        published_at: 2.days.ago + 1.minute,
        author: author1,
        tag_ids: [ tag1.id, tag2.id ],
        title:'recently published title',
        content: 'recently published content by author1, having tag1 and tag2, and 6 comments'
      )
    end
    let!(:trending_article_3) do
      create(
        :article,
        :commented,
        comments_count: 7,
        published: true,
        published_at: 2.days.ago + 1.minute,
        author: author2,
        tag_ids: [ tag2.id ],
        title:'recently published title',
        content: 'recently published content by author2, having tag2, and 7 comments'
      )
    end

    let!(:author1) { create(:author) }
    let!(:author2) { create(:author) }
    let!(:tag1) { create(:tag) }
    let!(:tag2) { create(:tag) }

    it 'returns all articles' do
      get :index

      expect(response).to have_http_status(:ok)
      expect(assigns(:articles)).to eq [
        un_published_article,
        published_article_1,
        published_article_2,
        recent_article_1,
        recent_article_2,
        trending_article_1,
        trending_article_2,
        trending_article_3
      ]
    end

    context 'when filter by search' do
      it 'returns articles with matching text in title or content' do
        get :index, params: { search: 'recently' }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          recent_article_1,
          recent_article_2,
          trending_article_1,
          trending_article_2,
          trending_article_3
        ]
      end
    end

    context 'when filter by authors' do
      it 'returns articles by selected authors' do
        get :index, params: { author_ids: [ author1.id ] }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          un_published_article,
          published_article_1,
          recent_article_1,
          trending_article_1,
          trending_article_2
        ]
      end
    end

    context 'when filter published articles' do
      it 'returns published articles' do
        get :index, params: { published: 'true' }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          published_article_1,
          published_article_2,
          recent_article_1,
          recent_article_2,
          trending_article_1,
          trending_article_2,
          trending_article_3
        ]
      end
    end

    context 'when filter un published articles' do
      it 'returns un published articles' do
        get :index, params: { published: 'false' }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [ un_published_article ]
      end
    end

    context 'when filter tagged articles' do
      it 'returns tagged articles' do
        get :index, params: { tagged: '1' }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          un_published_article,
          published_article_2,
          recent_article_1,
          recent_article_2,
          trending_article_1,
          trending_article_2,
          trending_article_3
        ]
      end
    end

    context 'when filter tagged articles with specific tags' do
      it 'returns tagged articles with specific tags' do
        get :index, params: { tagged: '1', tag_ids: [ tag1.id ] }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          un_published_article,
          recent_article_1,
          recent_article_2,
          trending_article_1,
          trending_article_2
        ]
      end
    end

    context 'when filter with specific tags without selecing tagged' do
      it 'returns all articles' do
        get :index, params: { tag_ids: [ tag1.id ] }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          un_published_article,
          published_article_1,
          published_article_2,
          recent_article_1,
          recent_article_2,
          trending_article_1,
          trending_article_2,
          trending_article_3
        ]
      end
    end

    context 'when filter by days' do
      it 'returns published articles published with in last number of days' do
        get :index, params: { days: 4 }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          recent_article_2,
          trending_article_1,
          trending_article_2,
          trending_article_3
        ]
      end
    end

    context 'when filter commented articles' do
      it 'returns commented articles' do
        get :index, params: { commented: '1' }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          recent_article_1,
          trending_article_1,
          trending_article_2,
          trending_article_3
        ]
      end
    end

    context 'when filter commented articles with specific comments count' do
      it 'returns commented articles with atleast number of specified comments' do
        get :index, params: { commented: '1', comments_count: 6 }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          trending_article_2,
          trending_article_3
        ]
      end
    end

    context 'when filter with specific comments counts without selecing commented' do
      it 'returns all articles' do
        get :index, params: { comments_count: 6 }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          un_published_article,
          published_article_1,
          published_article_2,
          recent_article_1,
          recent_article_2,
          trending_article_1,
          trending_article_2,
          trending_article_3
        ]
      end
    end

    context 'when filter by hot articles' do
      it 'returns recently published articles with comments' do
        get :index, params: { special: 'hot' }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          recent_article_1,
          trending_article_1,
          trending_article_2,
          trending_article_3
        ]
      end
    end

    context 'when filter by hot articles with search' do
      it 'returns recently published articles with comments and search text in title or content' do
        get :index, params: { special: 'hot', search: 'tag2' }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          recent_article_1,
          trending_article_2,
          trending_article_3
        ]
      end
    end

    context 'when filter by hot articles with specific authors' do
      it 'returns recently published articles by specific authors with comments' do
        get :index, params: { special: 'hot', author_ids: [ author2.id ] }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [ trending_article_3 ]
      end
    end

    context 'when filter by trending articles' do
      it 'returns trending articles' do
        get :index, params: { special: 'trending' }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          trending_article_3,
          trending_article_2,
          trending_article_1
        ]
      end
    end

    context 'when filter by trending articles with search' do
      it 'returns trending articles with search text in title or content' do
        get :index, params: { special: 'trending', search: 'tag2' }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [
          trending_article_3,
          trending_article_2
        ]
      end
    end

    context 'when filter by trending articles with specific authors' do
      it 'returns trending articles by specific authors' do
        get :index, params: { special: 'trending', author_ids: [ author2.id ] }

        expect(response).to have_http_status(:ok)
        expect(assigns(:articles)).to eq [ trending_article_3 ]
      end
    end

    describe 'pagination' do
      before do
        allow(Article).to receive(:default_per_page).and_return(4)
      end

      context 'when filter by page 1' do
        it 'returns first 4 articles' do
          get :index, params: { page: 1 }

          expect(response).to have_http_status(:ok)
          expect(assigns(:articles)).to eq [
            un_published_article,
            published_article_1,
            published_article_2,
            recent_article_1,
          ]
        end
      end

      context 'when filter by page 2' do
        it 'returns the second 4 articles' do
          get :index, params: { page: 2 }

          expect(response).to have_http_status(:ok)
          expect(assigns(:articles)).to eq [
            recent_article_2,
            trending_article_1,
            trending_article_2,
            trending_article_3
          ]
        end
      end

      context 'when filter by search and page 2' do
        it 'returns the page 2 articles with matching title or content' do
          get :index, params: { search: 'recently', page: 2 }

          expect(response).to have_http_status(:ok)
          expect(assigns(:articles)).to eq [ trending_article_3 ]
        end
      end
    end
  end
end
