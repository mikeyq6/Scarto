class GameController < ApplicationController
    
    def initialize
        @game = Game.new
    end

    def index
    # code to grab all posts so they can be
    # displayed in the Index view (index.html.erb)
    end

    def show
        @id = params[:id]
    # code to grab the proper Post so it can be
    # displayed in the Show view (show.html.erb)
    end

    def new
    # code to create an empty post and send the user
    # to the New view for it (new.html.erb), which will have a
    # form for creating the post
    end

    def create
        @name = params[:firstname]
        # Article.new(params.require(:article).permit(:title, :description))
    # code to create a new post based on the parameters that
    # were submitted with the form (and are now available in the
    # params hash)
    end

    def edit
    # code to find the post we want and send the
    # user to the Edit view for it (edit.html.erb), which has a
    # form for editing the post
    end

    def update
    # code to figure out which post we're trying to update, then
    # actually update the attributes of that post. Once that's
    # done, redirect us to somewhere like the Show page for that
    # post
    end

    def destroy
    # code to find the post we're referring to and
    # destroy it.  Once that's done, redirect us to somewhere fun.
    end
end
