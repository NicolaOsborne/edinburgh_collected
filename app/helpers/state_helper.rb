module StateHelper
  VIEWABLE_STATE_PATHS = [
    'my/memories',
    'my/scrapbooks',
  ]

  def button_for_state(action, state, moderatable, moderatable_name, reason=nil)
    link_name = action
    if reason
      state += " - #{reason}"
      link_name += " - #{reason}"
    end

    unless state_label_text(moderatable) == state
      url = send("#{action}_admin_moderation_#{moderatable_name}_path", moderatable, reason: reason)
      content_tag(:li, link_to(link_name.capitalize, url, class: "btn #{action}", method: :put))
    end
  end

  def state_label_text(moderatable)
    return moderatable.moderation_state unless moderatable.moderation_state == 'rejected'

    label = [moderatable.moderation_state, moderatable.moderation_reason]
    label.compact.join(' - ').strip
  end

  def show_state_label?(moderatable)
    current_user.try(:can_modify?, moderatable) &&
      show_state? &&
      !(moderatable.moderation_state == 'approved')
  end

  private

  def show_state?
    VIEWABLE_STATE_PATHS.include? controller_path
  end
end
