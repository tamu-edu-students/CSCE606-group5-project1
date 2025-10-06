module NavigationHelpers
  def path_for(page_name)
    case page_name.downcase
    when 'the home page', 'home'
      root_path
    when 'the calendar page', 'calendar'
      calendar_path
    when 'the dashboard page', 'dashboard'
      dashboard_path
    when 'the statistics page', 'statistics'
      statistics_path
    when 'the leetCode page', 'leetcode'
      leetcode_path
    when 'the profile page', 'profile'
      api_current_user_path
    when 'sign out', 'logout'
      logout_path
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
