class ArticlesController < ApplicationController
  before_action :set_variables, only: :index
  before_action :sanatize_params, only: :index

  def index
    @articles = Article.all

    @articles = @articles.search(params[:search]) if params[:search].present?
    @articles = @articles.by_authors(params[:author_ids]) if params[:author_ids].present?

    if params[:special] == 'hot'
        days = [params[:days].to_i, 7].max
        @articles = @articles.hot(days, params[:tag_ids])
    elsif params[:special] == 'trending'
      comments_count = [params[:comments_count].to_i, 5].max
      days = [params[:days].to_i, 3].max
      @articles = @articles.trending(comments_count, days, params[:tag_ids])
    else
      @articles = @articles.published if params[:published] == 'true'
      @articles = @articles.un_published if params[:published] == 'false'
      @articles = @articles.tagged(params[:tag_ids]) if params[:tagged] == '1'
      @articles = @articles.recent([params[:days].to_i, 1].max) if params[:days].present?

      @articles = @articles.commented([params[:comments_count].to_i, 1].max) if params[:commented] == '1'
    end
  end

  private

  def set_variables
    @authors = Author.all
    @tags = Tag.all
  end

  def sanatize_params
    params[:tag_ids] = params[:tag_ids]&.reject(&:blank?).map(&:to_i) if params[:tag_ids].present?
    params[:author_ids] = params[:author_ids]&.reject(&:blank?).map(&:to_i) if params[:author_ids].present?
  end
end
