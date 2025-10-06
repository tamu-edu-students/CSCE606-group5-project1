# frozen_string_literal: true

# Service module for LeetCode-related functionality
module Leetcode
  # Service class for fetching user statistics from LeetCode API
  # Provides methods to retrieve various user data including solved problems, calendar, and profile info
  class FetchStats
    # Base URL for LeetCode API from Rails configuration
    BASE = Rails.configuration.x.leetcode_api_base

    # Fetch solved problems statistics for a user
    # @param username [String] LeetCode username
    # @return [Hash] Hash with total, easy, medium, hard solved counts
    def solved(username)
      fetch_json("#{username}/solved")
        .then { |h| h.slice("solvedProblem", "easySolved", "mediumSolved", "hardSolved") }  # Extract relevant fields
        .then { |h| { total: h["solvedProblem"], easy: h["easySolved"], medium: h["mediumSolved"], hard: h["hardSolved"] } }  # Normalize keys
    end

    # Fetch submission calendar data for a user
    # @param username [String] LeetCode username
    # @return [Hash] Calendar data with submission information
    def calendar(username)
      data = fetch_json("#{username}/calendar")

      # submissionCalendar is returned as a JSON string, need to parse it into a hash
      if data["submissionCalendar"].is_a?(String)
        data["submissionCalendar"] = JSON.parse(data["submissionCalendar"])
      end
      data
    end

    # Fetch user profile information
    # @param username [String] LeetCode username
    # @return [Hash] User profile data
    def profile(username)
      fetch_json("userProfile/#{username}")
    end

    # Fetch recent accepted submissions for a user
    # @param username [String] LeetCode username
    # @param limit [Integer] Maximum number of submissions to fetch (default: 5)
    # @return [Array] Array of recent accepted submissions
    def accepted_submissions(username, limit: 5)
      fetch_json("#{username}/acSubmission?limit=#{limit}")["submission"] || []
    end

    # Fetch contest participation data for a user
    # @param username [String] LeetCode username
    # @return [Hash] Contest participation statistics
    def contest(username)
      fetch_json("#{username}/contest")
    end

    # Fetch programming language usage statistics
    # @param username [String] LeetCode username
    # @return [Hash] Language usage statistics
    def language_stats(username)
      fetch_json("languageStats?username=#{username}")
    end

    # Fetch skill-based problem solving statistics
    # @param username [String] LeetCode username
    # @return [Hash] Skill statistics breakdown
    def skill_stats(username)
      fetch_json("skillStats/#{username}")
    end

    private

    # Fetch JSON data from LeetCode API with caching and error handling
    # @param path [String] API endpoint path
    # @return [Hash] Parsed JSON response
    # @raise [String] Error message if request fails
    def fetch_json(path)
      # Cache API responses for 10 minutes to reduce API calls
      Rails.cache.fetch([ "lc", path ], expires_in: 10.minutes) do
        # Build full URI from base URL and path
        uri = URI.join(BASE, path)

        # Make HTTP request with timeouts for reliability
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 2, read_timeout: 3) do |http|
          http.request(Net::HTTP::Get.new(uri))
        end

        # Check for successful HTTP response
        raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)

        # Parse JSON response
        JSON.parse(res.body)
      end
    rescue JSON::ParserError => e
      # Handle JSON parsing errors
      Rails.logger.error("[LeetCodeAPI] JSON parse error for #{path}: #{e.message}")
      raise "Invalid JSON response"
    rescue => e
      # Handle any other errors (network, timeout, etc.)
      Rails.logger.warn("[LeetCodeAPI] #{path} failed: #{e.message}")
      raise
    end
  end
end
