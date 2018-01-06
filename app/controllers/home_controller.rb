class HomeController < ApplicationController
  #layout "empty"
  before_action :logged_in_user
  def index
  end
end
