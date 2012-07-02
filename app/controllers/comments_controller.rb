class CommentsController < BaseController

  before_filter :load_commentable, only: [:create, :update]

  def edit
    comment = Comment.find(params[:id])
    if current_user_can_manage?(comment)
      render partial: 'form', handlers: :haml, formats: :html,
                              locals: {comment: comment}
    else
      head :unauthorized
    end
  end

  def create
    comment = current_user.comments.new(params[:comment])
    comment.commentable = @commentable
    load_data_response(comment)

    if comment.save
      render json: { html: render_to_string( { partial: 'comment',
         handlers: :haml, formats: :html, locals: { comment: comment } }) }
    else
      if comment.parent_id?
        html = render_to_string({partial: 'reply_form',
          handlers: :haml, formats: :html,
          locals: {comment: comment, parent: comment.parent}})
      else
        html = render_to_string({partial: 'form',
          handlers: :haml, formats: :html,
          locals: {comment: comment}})
      end

      render json: {html: html}, status: :partial_content # :partial_content => 206
    end
  end

  def update
    comment = Comment.find(params[:id])
    if current_user_can_manage?(comment)
      if comment.update_attributes(params[:comment])
        render json: { html: render_to_string( { partial: 'comment',
           handlers: :haml, formats: :html, locals: { comment: comment } }) }
      else

        render json: {html: render_to_string( {partial: 'form',
           handlers: :haml, formats: :html, locals: {comment: comment}})},
           status: :partial_content # :partial_content => 206
      end
    else
      head :unauthorized
    end
  end

  def destroy
    comment = Comment.find(params[:id])
    if current_user_can_manage?(comment)
      comment.update_attribute(:removed, true)
      render json: {html: Comment::REMOVED_MESSAGE}
    else
      head :unauthorized
    end
  end

  protected
    def load_commentable
      klass = params[:comment].delete(:commentable_type).constantize
      @commentable = klass.find(params[:comment].delete(:commentable_id))
    end

    def load_data_response(comment)
      if comment.commentable.is_a?(DataResponse)
        @response = comment.commentable
      else
        @response = comment.commentable.data_response
      end
    end

    def current_user_can_manage?(comment)
      current_user.sysadmin?
    end
end
