class PostsController < ApplicationController
        before_action :authorize
        skip_before_action :authorize, only: [:index]

    # POST /alpha
    def alpha
        alpha_post = Post.alpha
        render json: alpha_post
    end

    # GET /posts
    def index
        posts = Post.all
        render json: posts.reverse
    end

    # GET /posts/:id
    def show
        post = find_post
        render json: { post: post }
    end

    # POST /posts
    def create
        if session[:user_id]
            post = Post.create(post_params)
            post.update!(user_id: session[:user_id])
            render json: post, include: ['user'], status: :created
        else
            render json: { errors: ["You must be logged in to create a post"] }, status: :unauthorized
        end
    end

    # DELETE /posts/:id
    def destroy
        post = find_post
        # byebug
        if post[:user_id] === session[:user_id]
            post.destroy
            head :no_content
        else
            render json: { errors: ["Not authorized"] }, status: :unauthorized
        end
    end

    # PATCH /posts/:id
    def update
        post = find_post
        if post[:user_id] == session[:user_id]
            post.update!(post_params)
            # byebug
            render json: post, include: ['user'], status: :accepted
        end
    end

    private

    def find_post
        Post.find(params[:id])
    end

    def post_params
        params.permit(:title, :content)
    end

    def authorize
        return render json: { error: "Not authorized" }, status: :unauthorized unless session.include? :user_id
    end


end
