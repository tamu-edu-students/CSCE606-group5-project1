module Api
  class UsersController < ApplicationController
    def profile
      if user_signed_in?
        render json: {
          id: current_user.id,
          name: current_user.full_name,
          first_name: current_user.first_name,
          email: current_user.email
        }
      else
        render json: { error: "Not signed in" }, status: :unauthorized
      end
    end
  end
end
