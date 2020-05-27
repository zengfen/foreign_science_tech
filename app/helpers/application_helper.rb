module ApplicationHelper

  def copyright
    Setting.copyright rescue "Copyright Beijing Social Data Max Ltd."
  end

  def copyrightyear
    Setting.copyrightyear rescue "2019-2020"
  end

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
    # time.strftime("%Y-%m-%d %H") rescue "-"
    time.strftime("%Y-%m-%d %H:%M:%S") rescue "-"

  end

  def show_format_time_y(time)
    time.strftime("%F %T") rescue "-"
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

  def show_format_date(time)
    return "" if time.blank?
    time = Time.parse(time.to_s).strftime("%F")
    return time
  end

  def show_html_original_string(str)
    return "" if str.blank?
    res = str.gsub(/\\/,"\\\\\\")
    res = res.gsub(/\n/,"\\n")
    res = res.gsub(/\r/,"\\r")
    res = res.gsub(/\f/,"\\f")
    res = res.gsub(/\t/,"\\t")
    res = res.gsub(/\v/,"\\v")
    return res
  end

end
