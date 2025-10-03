Rails.application.config.x.leetcode_api_base =
  ENV.fetch("LEETCODE_API_BASE", "https://alfa-leetcode-api.onrender.com")
Rails.application.config.x.leetcode_live =
  ActiveModel::Type::Boolean.new.cast(ENV.fetch("LEETCODE_LIVE_STATS", "true"))
