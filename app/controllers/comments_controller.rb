class CommentsController < BaseController
  def create
    @comment = current_user.comments.new(params[:comment])
    @comment.commentable = find_commentable
    load_data_response(@comment)

    if @comment.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Comment was successfully created."
          redirect_to :back
        end
        format.json { render :json => {:html => render_to_string(
          {:partial => 'comment.html.haml', :locals => {:comment => @comment}})}}
      end
    else
      respond_to do |format|
        format.html do
          flash[:error] = "You cannot create blank comment."
          redirect_to :back
        end
        format.json do
          if @comment.parent_id?
            html = render_to_string({:partial => 'reply_form.html.haml',
              :locals => {:comment => @comment, :parent => @comment.parent}})
          else
            html = render_to_string({:partial => 'form.html.haml',
              :locals => {:comment => @comment}})
          end

          render :json => {:html => html}, :status => :partial_content # :partial_content => 206
        end
      end
    end
  end


  protected
    def find_commentable
      klass = params[:commentable_type].constantize
      klass.find(params[:commentable_id])
    end

    def load_data_response(comment)
      if comment.commentable.is_a?(DataResponse)
        @response = comment.commentable
      else
        @response = comment.commentable.data_response
      end
    end
end
