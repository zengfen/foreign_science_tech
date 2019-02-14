class DomainDataController < ApplicationController
  before_action :logged_in_user

  def index
		@domain_datas = DomainDataSource.all
    if request.xhr?
     return render "_list_body.html.erb", layout: false
    end
	end



end