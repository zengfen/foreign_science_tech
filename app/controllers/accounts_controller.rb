class AccountsController < ApplicationController
  def index
    @templates = ControlTemplate.select("id, name").collect{|x| [x.name, x.id]}.to_a
    @accounts = Account.order('created_at desc').page(params[:page]).per(10)
    @account = Account.new
  end

  def new; end

  def create; end
end
