class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :current_user_only, only: [:edit, :update, :destroy]

  respond_to :html

  def index
    if (params[:user_id])
      user = User.find_by(id: params[:user_id])
      if (user_signed_in? && user == current_user)
        @notes = Note.includes(:position).where(:user_id => params[:user_id]).order(id: :desc).page(params[:page])
        @with_public = true
        @without_name = true
      else
        if user_signed_in? && current_user.is_admin?
          @notes = Note.includes(:position).where(:user_id => params[:user_id]).order(id: :desc).page(params[:page])
          @with_public = true
        else
          @notes = Note.includes(:position).where(:user_id => params[:user_id], :public => true).order(id: :desc).page(params[:page])
        end
      end
      @list_title = user.username + "さんのマイノート一覧"
    else
      if user_signed_in? && current_user.is_admin?
        @notes = Note.includes(:user, :position).order(created_at: :desc).page(params[:page])
        @with_public = true
      else
        @notes = Note.where(public: true).includes(:user, :position).order(created_at: :desc).page(params[:page])
      end
      @list_title = "最新マイノート"
    end
    respond_with(@notes)
  end

  def show
    if (@note.public)
      Note.increment_counter(:views, @note.id)
      @note.views += 1
    else
      raise UserException::AccessDenied unless (user_signed_in? && (@note.user_id == current_user.id || current_user.is_admin?))
    end
    @comments = @note.comments.includes(:user).order(id: :desc)
    @comment = Comment.new
    @comment.user_id = user_signed_in? ? current_user.id : 0
    @comment.note_id = @note.id
    respond_with(@note)
  end

  def new
    @note = Note.new
    @note.user_id = current_user.id
    @note.position_id = params[:id]
    respond_with(@note)
  end

  def edit
  end

  def create
    @note = Note.new(note_params)
    if (params[:preview])
      render 'new' and return
    end
    current_user_only
    @note.save!
    @note.update_references
    if @note.public
      @note.create_activity(action: 'create', owner: current_user, recipient: @note.position)
      watchers = @note.position.watchers
      watchers.each do |watcher|
        Feeder.delay.note_to_watcher(watcher.id, @note.id) if watcher.receive_watching
      end
      watcher_ids = watchers.pluck(:id)
      @note.user.followers.each do |follower|
        unless watcher_ids.include?(follower.id)
          Feeder.delay.note_to_follower(follower.id, @note.id) if follower.receive_following
        end
      end
      bot_tweet(@note.to_create_tweet)
    end
    respond_with(@note)
  end

  def update
    if (params[:preview])
      @note.assign_attributes(note_params)
      render 'edit' and return
    end
    @note.update(note_params)
    @note.update_references
    respond_with(@note)
  end

  def destroy
    @note.destroy
    redirect_to position_path(@note.position_id)
  end

  private
    def set_note
      @note = Note.find(params[:id])
    end

    def note_params
      params[:note][:title] = '(無題)' if params[:note][:title] == ''
      params.require(:note).permit(:title, :content, :user_id, :position_id, :public, :category)
    end

    def current_user_only
      raise UserException::AccessDenied unless (@note.user_id == current_user.id)
    end
end
