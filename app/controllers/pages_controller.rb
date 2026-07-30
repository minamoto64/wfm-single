class PagesController < ApplicationController
  allow_unauthenticated_access
  before_action :resume_session

  def home
    redirect_to interactions_path if Current.user.present?
  end
end
