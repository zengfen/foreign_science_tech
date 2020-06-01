class DataCentersController < ApplicationController
  before_action :logged_in_user

  def index
    @data = [
      {},
      {},
      {},
      {},
      {},
      {},
      {},
      {}
    ]
  end
end