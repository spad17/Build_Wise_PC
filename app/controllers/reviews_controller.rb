class ReviewsController < ApplicationController
  before_action :require_login
  before_action :set_component

  def create
    review = @component.reviews.new(review_params.merge(user: current_user))
    save_review(review)
  end

  def update
    review = current_user.reviews.where(component: @component).find(params[:id])
    review.assign_attributes(review_params)
    save_review(review)
  end

  def destroy
    current_user.reviews.where(component: @component).find(params[:id]).destroy!
    redirect_to component_path(@component, build_id: @context_build&.id), notice: "Отзыв удалён."
  end

  private

  def set_component
    @component = Component.find(params[:component_id])
    @context_build = current_user.builds.find(params[:build_id]) if params[:build_id].present?
  end

  def review_params
    params.require(:review).permit(:rating, :body)
  end

  def save_review(review)
    if review.save
      redirect_to component_path(@component, build_id: @context_build&.id), notice: "Отзыв сохранён."
    else
      redirect_to component_path(@component, build_id: @context_build&.id), alert: review.errors.full_messages.to_sentence
    end
  end
end
