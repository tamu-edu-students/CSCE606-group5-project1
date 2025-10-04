# frozen_string_literal: true

module Leetcode
  class FetchStats
    BASE = Rails.configuration.x.leetcode_api_base

    def solved(username)
      fetch_json("#{username}/solved")
        .then { |h| h.slice("solvedProblem", "easySolved", "mediumSolved", "hardSolved") }
        .then { |h| { total: h["solvedProblem"], easy: h["easySolved"], medium: h["mediumSolved"], hard: h["hardSolved"] } }
    end

    def calendar(username)
      data = fetch_json("#{username}/calendar")
      # submissionCalendar is a JSON string, need to parse it
      if data["submissionCalendar"].is_a?(String)
        data["submissionCalendar"] = JSON.parse(data["submissionCalendar"])
      end
      data
    end

    def profile(username)
      fetch_json("userProfile/#{username}")
    end

    def accepted_submissions(username, limit: 5)
      fetch_json("#{username}/acSubmission?limit=#{limit}")["submission"] || []
    end

    def contest(username)
      fetch_json("#{username}/contest")
    end

    def language_stats(username)
      fetch_json("languageStats?username=#{username}")
    end

    def skill_stats(username)
      fetch_json("skillStats/#{username}")
    end

    private

    def fetch_json(path)
      Rails.cache.fetch([ "lc", path ], expires_in: 10.minutes) do
        uri = URI.join(BASE, path)
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 2, read_timeout: 3) do |http|
          http.request(Net::HTTP::Get.new(uri))
        end
        raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)
        JSON.parse(res.body)
      end
    rescue JSON::ParserError => e
      Rails.logger.error("[LeetCodeAPI] JSON parse error for #{path}: #{e.message}")
      raise "Invalid JSON response"
    rescue => e
      Rails.logger.warn("[LeetCodeAPI] #{path} failed: #{e.message}")
      raise
    end
  end
end
