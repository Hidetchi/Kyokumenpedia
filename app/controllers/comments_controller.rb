class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]
  before_action :current_user_only, only: [:destroy]

  respond_to :html

  def create
    @comment = Comment.new(comment_params)
    current_user_only
    if (prev_comment = Note.find(@comment.note_id).comments.last) # num is counter column
      @comment.num = prev_comment.num + 1
    else
      @comment.num = 1
    end
    @comment.save

    # Mail recipients
    user_ids = [@comment.note.user_id]
    @comment.note.comments.last(6).each do |comment|
      user_ids = user_ids | [comment.user_id]
    end
    user_ids.each do |user_id|
      Feeder.delay.notify_comment(user_id, @comment.id) unless (current_user.id == user_id)
    end

    redirect_to note_path(@comment.note_id)
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to note_path(@comment.note_id)
  end

  private
    def comment_params
      params.require(:comment).permit(:user_id, :note_id, :content)
    end

    def current_user_only
      raise UserException::AccessDenied unless (@comment.user_id == current_user.id)
    end
end
