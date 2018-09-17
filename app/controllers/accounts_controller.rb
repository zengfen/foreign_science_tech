class AccountsController < ApplicationController
  def index
    @templates = ControlTemplate.select('id, name').where(has_account: true).collect { |x| [x.name, x.id] }.to_a
    @accounts = Account.where(control_template_id: @templates.collect{|x| x[1]}).order('created_at desc').page(params[:page]).per(50)
    @account = Account.new


  end

  def new; end

  def create
    account_params = params
    .require(:account)
    .permit(:contents, :valid_ips, :control_template_id, :valid_time, :account_type)

    @account = Account.new(account_params)
    Rails.logger.info(@account.valid_ips)
    message = @account.save_with_split!

    flash[message.keys.first.to_sym] = message.values.first

    redirect_back(fallback_location: accounts_path)
  end

  def destroy
    @account = Account.find_by(id: params[:id])
    redirect_to root_path if @account.blank?
    render json: { type: 'success', message: '操作成功！' } if @account.destroy
  end


  def ip_list
    template = ControlTemplate.find(params[:id])
    @ips = DispatcherHost.where(is_internal: template.is_internal).collect(&:ip)
    @agent_ips = DispatcherHostServiceWorker.where(service_name: "agent", ip: @ips).group(:ip, :service_name).collect(&:ip)



    render layout: false
  end
end
