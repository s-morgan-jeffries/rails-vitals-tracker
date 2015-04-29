class SessionsController < ApplicationController

  def new
  end

  def create
    # Find the user by email address
    user = User.find_by(email: params[:session][:email])
    # If the user exists AND it authenticates the password...
    if user && user.authenticate(params[:session][:password])
      # If the user is activated, do the login stuff
      if user.activated?
        # SessionHelper#log_in: Set the :user_id key on the session "hash" with the user's id.
        # So here's the trick. The session we've got here is the one that was found by looking at the session cookie
        # from the request. Rails is re-generating the cookie on each request and telling the browser to update its
        # value. The specific cookie can be configured in config/initializers/session_store.rb.
        # So after a considerable amount of searching, I've at least discovered that session data is indeed stored in
        # the cookie. The keys include a :session_id and, in this app, :_csrf_token and :user_id.
        # If you use a store other than the cookie store, the unencrypted :session_id is sent to the user agent as a
        # cookie, but that's all that's exposed. At least for the activerecord store, the data is stored as a base64
        # encoded string in the data column.
        # t0d0: Figure out how Rails is storing the session in the cookie

        # In any case, once we've authenticated, that's it.
        log_in user
        # Check if the :remember_me flag is set. If so, remember the user. Otherwise, forget him.
        #
        # params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
      else # otherwise, notify the user that she needs to activate her account
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
