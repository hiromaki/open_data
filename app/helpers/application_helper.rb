module ApplicationHelper

  def str_ellipsis(value, len)
    if value. present?
      if value.length > len
        value.to_s[0,len] + "..."
      else
        value
      end
    end
  end
end
