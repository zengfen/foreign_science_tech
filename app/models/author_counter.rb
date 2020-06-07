class AuthorCounter < ApplicationRecord

  def self.init_author_counter
    TData.where.not(con_author:["",nil,"[]"]).each do |x|
      authors = JSON.parse(x.con_author) rescue nil
      return if authors.blank?
      date = x.con_time.to_date
      authors.each do |author|
        data = AuthorCounter.where(con_author:author).where(con_date:date).first
        if data.present?
          data.update(count:data.count + 1)
        else
          AuthorCounter.create(con_date:author,con_date:date,count:1)
        end
      end
    end
  end

  def self.during(start_date, end_date)
    self.where("con_date>=? and con_date <=?",start_date.to_date,end_date.to_date)
  end



end