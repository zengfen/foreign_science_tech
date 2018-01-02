class TemplatesController < ApplicationController
	before_action :logged_in_user
	def list
  	lists = 20.times.collect{|x| 6.times.collect{|y| "数据#{x+1}-#{y+1}"}} 
    @lists = Kaminari.paginate_array(lists).page(params[:page]).per(10) 
  end

  def test
  	
  end
end
