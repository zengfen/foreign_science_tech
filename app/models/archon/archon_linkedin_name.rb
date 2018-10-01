class ArchonLinkedinName < ArchonBase
  def self.fix_user
    ids = ArchonLinkedinUser.select("id").collect(&:id)
    invalid_ids = []

    i = 0
    ids.each_slice(100).each do |temp_ids|
      puts i
      i += 1
      valid_ids = []
      temp_ids.each do |x|
        if x.include?("?") || x.include?("/")
          invalid_ids << x
        else
          valid_ids << x
        end
      end

      users = ArchonLinkedinUser.select("id").where(id: valid_ids).where("experience='' and education='' and skills=''").collect(&:id)
      users0 = valid_ids - users

      results = []
      users.each do |x|
        results << {id: x, is_dump: false}
      end

      users0.each do |x|
        results << {id: x, is_dump: true}
      end

      ArchonLinkedinName.create(results)
    end


    ArchonLinkedinUser.where(id: invalid_ids).delete_all
  end


  def self.remove_users
    ids = ArchonLinkedinName.select("id").where("is_dump = 0").collect(&:id)
    ids.each_slice(100).each do |temp_ids|
      ArchonLinkedinUser.where(id: temp_ids).delete_all
    end
  end
end
