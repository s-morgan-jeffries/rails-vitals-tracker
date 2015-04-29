class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  # Password reset form
  def new
  end

  # What happens after you submit that form
  def create
    # Find the user
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      # Create the digest
      @user.create_reset_digest
      # Send the email
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  # What the password reset email links to. It's a form that allows you to reset the password.
  def edit
  end
  
  # Submitting the form from the :edit action triggers this.
  def update
    # This is a little funky to me. The second and third branches of this thing essentially just attempt to update the
    # user and then re-render the form if that fails. It's sort of like what UsersController#update does. The user
    # model itself will check to see if the :password_confirmation matches :password. All we have to do here is to make
    # sure the :password param exists.
    if password_blank?
      flash.now[:danger] = "Password can't be blank"
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  private
    
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
    
    # Returns true if password is blank.
    def password_blank?
      params[:user][:password].blank?
    end
  
    # Before filters

    # Gets the user identified in the params hash
    def get_user
      @user = User.find_by(email: params[:email])
    end
    
    # Confirms a valid user.
    #
    def valid_user
      unless (@user && @user.activated? && 
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end      
    end
    
    # Checks expiration of reset token.
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
