class AuthorCounter < ApplicationRecord

  def self.init_author_counter
    TData.where.not(con_author:["",nil,"[]"]).each do |x|
      authors = JSON.parse(x.con_author) rescue nil
      return if authors.blank?
      date = x.con_time.strftime("%Y%m%d")
      authors.each do |author|
        data = AuthorCounter.where(author_name:author,current_date:date).first
        if data.present?
          data.update(count:data.count + 1)
        else
          AuthorCounter.create(author_name:author,current_date:date,count:1)
        end
      end
    end
  end

  def self.during(start_date, end_date)
    self.where("current_date>=? and current_date <=?",start_date.strftime("%F%m%d"),end_date.strftime("%F%m%d"))
  end



end