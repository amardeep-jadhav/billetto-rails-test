class SessionsController < ApplicationController
  def destroy
    cookies.delete("__session", domain: :all)
    cookies.delete("__client", domain: :all)
    reset_session

    redirect_to events_path, notice: "Signed out."
  end
end