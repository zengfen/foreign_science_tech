class ArchonWikidata < ArchonBase

  def self.update_social(id, fb, tw)
    x = ArchonWikidata.find(id)
    if !fb.blank?
      x.facebook = [fb].to_json
    end

    if !tw.blank?
      x.twitter = [tw].to_json
    end

    x.save
  end


end


