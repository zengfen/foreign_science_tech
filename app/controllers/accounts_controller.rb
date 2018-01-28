class AccountsController < ApplicationController
  def index
    @templates = ControlTemplate.select('id, name').collect { |x| [x.name, x.id] }.to_a
    @accounts = Account.order('created_at desc').page(params[:page]).per(10)
    @account = Account.new
  end

  def new; end

  def create
    account_params = params
                     .require(:account)
                     .permit(:contents, :control_template_id, :valid_time, :account_type)

    @account = Account.new(account_params)
    message = @account.save_with_split!

    flash[message.keys.first.to_sym] = message.values.first

    redirect_back(fallback_location: accounts_path)
  end
end
