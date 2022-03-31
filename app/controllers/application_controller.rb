class ApplicationController < ActionController::API
  before_action :authorized

  def passwords_dont_match
    params[:password] != params[:password_confirmation]
  end

  def user_already_exists
    User.find_by(email: params[:email])
  end

  def email_formatted_incorrectly(user)
    user.errors.messages[:email]
  end

  def encode_token(payload)
    JWT.encode(payload, 'secret')
  end

  def auth_header
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      begin
        JWT.decode(token, 'secret', true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def current_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!current_user
  end

  def authorized
    render json: { message: 'Please log in'}, status: :unauthorized unless logged_in?
  end
end
