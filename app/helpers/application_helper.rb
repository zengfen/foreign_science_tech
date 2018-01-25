module ApplicationHelper
  def is_active_controller(controller_names)
    controller_names.split(",").include?(params[:controller]) ? "active" : nil
  end

  def is_active_action(action_name, controller_name = nil)
    if action_name.blank?
      return params[:controller] == controller_name ? "active" : nil
    end
    if controller_name.blank?
      return params[:action] == action_name ? "active" : nil
    end

    if !action_name.blank? && !controller_name.blank?
      return (params[:action] == action_name && params[:controller] == controller_name ) ? "active" : nil
    end

    nil
  end

  def is_active_params(params,key,value)
    params[key] == value ? "active" : nil
  end
  
  def show_boolean_cn(obj)
  	(obj)? "是":"否" rescue "-"
  end

  def show_format_time(time)
    time.strftime("%Y-%m-%d %H:%M:%S") rescue "-"
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
