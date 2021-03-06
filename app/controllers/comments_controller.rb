class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :update]
  before_action :authorized

  # GET /comments by activity
  def index
    puts params[:id]
    puts @user.id
    @comments = Comment.where({activity_id: params[:id]})
    if !@comments.exists?
    render json: {
        error: 'There are no available comments'
    }
    else
      annotated_comments = []
      @comments.each do |c|
        annotated_comments.push({
                                    can_delete: @user.id == c.user_id,
                                    comment: c
                                })
      end
      render json: annotated_comments
    end
  end

  # # GET /comments/1 by activity
  # def show
  #   @onecomment = activity.exists?(params[:location_id])
  # end
  #   if @onecomment
  #   render json: @comment
  # end

  # POST /comments
  def create

    @comment = Comment.new(comment_params)
    @comment.user_id = @user.id
    if User.exists?(@comment.user_id)
      if @comment.save
        render json: @comment, status: :created, location: @comment
      else
        render json: @comment.errors, status: :unprocessable_entity
      end
    else
      render json: {
          error: 'User or activity does not exist'
      }
    end
  end

  # PATCH/PUT /comments/1
  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def user
    render json: Comment.where({user_id:@user.id})
  end

  # DELETE /comments/1
  def destroy
    @comment = Comment.find_by_id(params[:id])
    # puts @user
    render json: {
        deleted: !!(@comment && @comment.user_id == @user.id && @comment.destroy) #true if deleted, false if incorrect user or no comment exists
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end


    # Only allow a trusted parameter "white list" through.
    def comment_params
      params.require(:comment).permit(:message, :activity_id)
    end
end
