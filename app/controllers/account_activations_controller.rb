class AccountActivationsController < ApplicationController

  # Sort of a funny controller. There's no model and no template.
  def edit
    # Find the user according to the named email parameter
    user = User.find_by(email: params[:email])
    # If the user exists and isn't activated, and if the :id param (which is the activation token) authenticates (i.e.
    # digests to the same thing that's saved in the user's record)...
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # Activate the user (set :activated to true and set the :activated_at time)
      user.activate
      # Add the user's :id to the session hash under :user_id
      log_in user
      # Set the :success key on the flash. Remember, the whole role of the flash is to hang on to something through one
      # request cycle and then automatically clear it.
      flash[:success] = "Account activated!"
      # Now redirect to the user's show page.
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
