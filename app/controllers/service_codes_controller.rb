class ServiceCodesController < ApplicationController

  def index
    ServiceCode.init_all

    @codes = ServiceCode.all
  end

end
