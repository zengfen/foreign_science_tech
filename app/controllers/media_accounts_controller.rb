class MediaAccountsController < ApplicationController
  before_action :logged_in_user

  def index
    opts,opts1 = {},{}
    if !params[:keyword].blank?
	    opts[:name] = params[:keyword] 
	    opts1[:short_name] = params[:keyword]
    end

    @media_accounts = MediaAccount.where(opts).or(MediaAccount.where(opts1)).order("created_at desc").page(params[:page]).per(20)
  end

end
