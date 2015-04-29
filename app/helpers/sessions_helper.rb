module SessionsHelper

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # # Remembers a user in a persistent session.
  # def remember(user)
  #   # This generates a virtual attribute, :remember_token, on the user. It then digests that token and persists that
  #   # value as the user's :remember_digest attribute.
  #   user.remember
  #   cookies.permanent.signed[:user_id] = user.id
  #   cookies.permanent[:remember_token] = user.remember_token
  # end

  # Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end

  # Returns the current logged-in user (if any).
  # This caches the @current_user the first time it's called
  def current_user
    # If there's a :user_id key in the session, just use that
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    # elsif (user_id = cookies.signed[:user_id]) # Otherwise, check to see if there's a :user_id in the signed cookies.
    #   # Find the user by their id
    #   user = User.find_by(id: user_id)
    #   # Now check to see if the :remember_token in the cookies matches the :remember_digest. This is comparable to what
    #   # happens with passwords.
    #   if user && user.authenticated?(:remember, cookies[:remember_token])
    #     # This just sets the :user_id on the session hash so we don't have to go through this next time.
    #     log_in user
    #     # And this sets the instance variable @current_user
    #     @current_user = user
    #   end
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # # Forgets a persistent session.
  # def forget(user)
  #   # This just clears out the :remember_digest attribute for the user
  #   user.forget
  #   # Deletes the :user_id and :remember_token cookies (if they exist)
  #   cookies.delete(:user_id)
  #   cookies.delete(:remember_token)
  # end

  # Logs out the current user.
  def log_out
    # forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end
end
