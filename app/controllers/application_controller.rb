class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  if !Rails.env.development?
    rescue_from ActiveRecord::RecordNotFound, Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from UserException::AccessDenied, with: :render_403
  end

  def routing_error
    raise ActionController::RoutingError.new(params[:path])
  end

  private
  
  def render_404(e=nil)
    if e
      logger.info "Rendering 404 with exception: #{e.message}"
      e.backtrace.each do |line|
        logger.info "---#{line}" unless (line =~ /\/rbenv\/versions\// || line =~ /\/\.rvm\/gems\//)
      end
    end
    @title = "404エラー"
    @header = "ページが見つかりません"
    @caption = "お探しのページは見つかりませんでした。"
    render template: 'pages/error', status: 404, layout: 'application', content_type: 'text/html'
  end
  
  def render_403(e=nil)
    if e
      logger.info "Rendering 403 with exception: #{e.message}"
      e.backtrace.each do |line|
        logger.info "---#{line}" unless (line =~ /\/rbenv\/versions\// || line =~ /\/\.rvm\/gems\//)
      end
    end
    @title = "認証エラー"
    @header = "アクセス権がありません"
    @caption = "お使いのアカウントはこの機能へのアクセス権がありません。"
    render template: 'pages/error', status: 403, layout: 'application', content_type: 'text/html'
  end
  
  def render_500(e=nil)
    if e
      logger.info "Rendering 500 with exception: #{e.message}"
      e.backtrace.each do |line|
        logger.info "---#{line}" unless (line =~ /\/rbenv\/versions\// || line =~ /\/\.rvm\/gems\//)
      end
    end
    @title = "サーバエラー"
    @header = "エラーが発生しました"
    @caption = "サーバ内にてエラーが発生しました。ご迷惑をおかけし大変申し訳ありません。"
    render template: 'pages/error', status: 500, layout: 'application', content_type: 'text/html'
  end
 
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username
  end
end
