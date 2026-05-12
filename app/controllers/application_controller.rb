class ApplicationController < ActionController::Base
  include Clerk::Authenticatable

  allow_browser versions: :modern

  helper_method :current_user_id, :signed_in?, :clerk_sign_in_url

  private

  def require_clerk_session!
    return if clerk.session

    redirect_to clerk_sign_in_url, allow_other_host: true
  end

  def current_user_id
    clerk.user_id
  end

  def signed_in?
    current_user_id.present?
  end

  def clerk_sign_in_url
    ENV["CLERK_SIGN_IN_URL"]
  end
end