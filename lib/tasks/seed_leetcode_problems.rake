namespace :leet_code do
  desc "Seed LeetCode problems with description and tags using external API"
  task seed: :environment do
    require "net/http"
    require "json"
    require "uri"

    BASE_URL = "https://leetcode-api-pied.vercel.app"
    problems_url = URI("#{BASE_URL}/problems")
    response = Net::HTTP.get_response(problems_url)

    unless response.is_a?(Net::HTTPSuccess)
      puts "Failed to fetch problems list"
      return
    end

    problems = JSON.parse(response.body)
    puts "Retrieved #{problems.size} problems. Seeding up to 200..."

    count = 0
    problems.first(200).each do |p|
      begin
        # Fetch detailed data
        detail_url = URI("#{BASE_URL}/problem/#{p['id']}")
        detail_response = Net::HTTP.get_response(detail_url)

        unless detail_response.is_a?(Net::HTTPSuccess)
          puts "Failed to fetch details for problem ID #{p['id']}"
          next
        end

        detail = JSON.parse(detail_response.body)

        # Extract and sanitize data
        leetcode_id = p["frontend_id"]
        title = p["title"]
        title_slug = p["title_slug"]
        difficulty = p["difficulty"].downcase
        url = p["url"]
        description = detail["content"]
        tags = detail["topicTags"].map { |tag| tag["name"] }.join(", ")

        # Save to DB
        problem = LeetCodeProblem.find_or_initialize_by(leetcode_id: leetcode_id.to_s)
        problem.update!(
          title: title,
          title_slug: title_slug,
          difficulty: difficulty,
          url: url,
          tags: tags,
          description: description
        )

        puts "Saved ##{leetcode_id}: #{title} (#{difficulty.capitalize})"
        count += 1

      rescue => e
        puts "Error saving problem #{p['title']}: #{e.message}"
        next
      end
    end

    puts "Seeded #{count} LeetCode problems with full details"
  end
end
