class ArchonWikidata < ArchonBase

  def update_social(fb, tw)
    x = self
    if !fb.blank?
      x.facebook = [fb].to_json
    end

    if !tw.blank?
      x.twitter = [tw].to_json
    end

    x.save
  end


end


