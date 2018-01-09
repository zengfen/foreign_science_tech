class SocialAccountsController < ApplicationController
	before_action :logged_in_user
  def index
    opts = {}
    opts[:name] = params[:keyword] if !params[:keyword].blank?
    opts[:account_type] = params[:account_type] if !params[:account_type].blank?
    opts[:account_category] = params[:account_category] if !params[:account_category].blank?
    @social_accounts = SocialAccount.where(opts).order("created_at desc").page(params[:page]).per(20)
  end
end