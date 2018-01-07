class MediaAccountsController < ApplicationController
	before_action :logged_in_user

	def index
		opts = {}
    opts[:name] = params[:keyword] if !params[:keyword].blank?
		@media_accounts = MediaAccount.where(opts).order("created_at desc").page(params[:page]).per(20)
	end
end
