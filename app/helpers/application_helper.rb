module ApplicationHelper
  def is_active_controller(controller_names)
    controller_names.split(",").include?(params[:controller]) ? "active" : nil
  end

  def is_active_action(action_names)
    action_names.split(",").include?(params[:action]) ? "active" : nil
  end

  def show_boolean_cn(obj)
  	(obj)? "是":"否" rescue "-"
  end

  def show_format_time(time)
    time.strftime("%Y-%m-%d %H:%M:%S") rescue nil
  end

  def truncate_utf(text, length = 15, truncate_string = "")
    l=0
    char_array=(text || "").unpack("U*")
    char_array.each_with_index do |c,i|
      l = l+ (c<127 ? 0.5 : 1)
      if l>=length
        return char_array[0..i].pack("U*")+(i<char_array.length-1 ? truncate_string : "")
      end
    end
    return text
  end

end
