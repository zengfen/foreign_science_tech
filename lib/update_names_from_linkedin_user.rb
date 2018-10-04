class UpdateNamesFromLinkedinUser
  def self.add_names_from_linkedin_user
    ArchonLinkedinUser.select("id").find_in_batches do |users|
      insert_names = []
      ids = users.map{|x| x["id"]}
      update_ids = ArchonLinkedinName.select("id").where(id:ids).map{|x| x["id"]}
      create_ids = ids - update_ids

      create_ids.each do |id|
        linkedin_name = []
        linkedin_name << id
        linkedin_name << true
        linkedin_name << true
        insert_names << linkedin_name
      end

      ArchonLinkedinName.where(id: update_ids).update_all(is_finish: true, is_dump: true, is_invalid: false)
      create_sql = "INSERT INTO #{ArchonLinkedinName.table_name} (id,is_dump,is_finished) VALUES #{insert_names.map {|rec| "(#{rec.join(", ")})" }.join(" ,")}"
      ArchonLinkedinName.connection.insert_sql(create_sql)
    end
  end
end
