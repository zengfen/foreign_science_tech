class DomainDataController < ApplicationController
  before_action :logged_in_user

  def index
    page = (params[:page] || 1).to_i
    per_page = (params[:per] || 50).to_i
    keyword = params[:keyword]
    @lists = DomainDataSource.where("domain like ?", "%#{params[:keyword]}%")page(page).per(per_page)
    if request.xhr?
     return render "_list_body.html.erb", layout: false
    end
  end



end