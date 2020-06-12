class AuthorCounter < ApplicationRecord

  def self.init_author_counter
    TData.where.not(con_author:["",nil,"[]"]).select("data_id,con_author,con_time").find_each do |x|
      authors = JSON.parse(x.con_author) rescue nil
      next if authors.blank?
      date = x.con_time.to_date
      authors.each do |author|
        data = AuthorCounter.where(con_author:author).where(con_date:date).first
        if data.present?
          data.update(count:data.count + 1)
        else
          AuthorCounter.create(con_author:author,con_date:date,count:1)
        end
      end
    end
  end

  def self.during(start_date, end_date)
    self.where("con_date>=? and con_date <=?",start_date.to_date,end_date.to_date)
  end



end