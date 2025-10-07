require 'rails_helper'
require 'rake'

RSpec.describe 'leet_code:seed', type: :task do
  before(:all) do
    Rake.application.rake_require('tasks/seed_leetcode_problems')
    Rake::Task.define_task(:environment)
  end

  let(:task) { Rake::Task['leet_code:seed'] }
  
  before do
    task.reenable
    LeetCodeProblem.delete_all
  end

  let(:problems_list_response) do
    [
      {
        'id' => 1,
        'frontend_id' => 1,
        'title' => 'Two Sum',
        'title_slug' => 'two-sum',
        'difficulty' => 'Easy',
        'url' => 'https://leetcode.com/problems/two-sum'
      },
      {
        'id' => 2,
        'frontend_id' => 2,
        'title' => 'Add Two Numbers',
        'title_slug' => 'add-two-numbers',
        'difficulty' => 'Medium',
        'url' => 'https://leetcode.com/problems/add-two-numbers'
      }
    ]
  end

  let(:problem_detail_response) do
    {
      'content' => '<p>Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.</p>',
      'topicTags' => [
        { 'name' => 'Array' },
        { 'name' => 'Hash Table' }
      ]
    }
  end

  describe 'successful seeding' do
    before do
      stub_request(:get, 'https://leetcode-api-pied.vercel.app/problems')
        .to_return(status: 200, body: problems_list_response.to_json)

      stub_request(:get, 'https://leetcode-api-pied.vercel.app/problem/1')
        .to_return(status: 200, body: problem_detail_response.to_json)

      stub_request(:get, 'https://leetcode-api-pied.vercel.app/problem/2')
        .to_return(status: 200, body: problem_detail_response.to_json)
    end

    it 'creates problems with correct details including lowercase difficulty' do
      expect {
        capture_stdout { task.invoke }
      }.to change(LeetCodeProblem, :count).by(2)
      
      problem = LeetCodeProblem.find_by(leetcode_id: '1')
      expect(problem.title).to eq('Two Sum')
      expect(problem.title_slug).to eq('two-sum')
      expect(problem.difficulty).to eq('Easy')
      expect(problem.url).to eq('https://leetcode.com/problems/two-sum')
      expect(problem.tags).to eq('Array, Hash Table')
      expect(problem.description).to include('Given an array of integers')
    end

    it 'outputs progress messages' do
      output = capture_stdout { task.invoke }
      
      expect(output).to include('Retrieved 2 problems')
      expect(output).to include('Saved #1: Two Sum (Easy)')
      expect(output).to include('Seeded 2 LeetCode problems')
    end
  end

  describe 'updating existing problems' do
    let!(:existing_problem) do
      create(:leet_code_problem, 
        leetcode_id: '1',
        title: 'Old Title',
        difficulty: 'hard'
      )
    end

    before do
      stub_request(:get, 'https://leetcode-api-pied.vercel.app/problems')
        .to_return(status: 200, body: [problems_list_response.first].to_json)

      stub_request(:get, 'https://leetcode-api-pied.vercel.app/problem/1')
        .to_return(status: 200, body: problem_detail_response.to_json)
    end

    it 'updates existing problems instead of creating duplicates' do
      expect {
        capture_stdout { task.invoke }
      }.not_to change(LeetCodeProblem, :count)
      
      existing_problem.reload
      expect(existing_problem.title).to eq('Two Sum')
      expect(existing_problem.difficulty).to eq('Easy')
    end
  end

  describe 'limits and error handling' do
    it 'limits seeding to 200 problems' do
      large_problems_list = (1..250).map do |i|
        {
          'id' => i, 'frontend_id' => i, 'title' => "Problem #{i}",
          'title_slug' => "problem-#{i}", 'difficulty' => 'Easy',
          'url' => "https://leetcode.com/problems/problem-#{i}"
        }
      end

      stub_request(:get, 'https://leetcode-api-pied.vercel.app/problems')
        .to_return(status: 200, body: large_problems_list.to_json)

      (1..200).each do |i|
        stub_request(:get, "https://leetcode-api-pied.vercel.app/problem/#{i}")
          .to_return(status: 200, body: problem_detail_response.to_json)
      end

      output = capture_stdout { task.invoke }
      
      expect(output).to include('Retrieved 250 problems. Seeding up to 200')
      expect(LeetCodeProblem.count).to eq(200)
    end

    it 'handles API failures gracefully' do
      stub_request(:get, 'https://leetcode-api-pied.vercel.app/problems')
        .to_return(status: 500)

      output = capture_stdout { task.invoke }
      
      expect(output).to include('Failed to fetch problems list')
      expect(LeetCodeProblem.count).to eq(0)
    end

    it 'skips individual problem failures and continues' do
      stub_request(:get, 'https://leetcode-api-pied.vercel.app/problems')
        .to_return(status: 200, body: [problems_list_response.first].to_json)

      stub_request(:get, 'https://leetcode-api-pied.vercel.app/problem/1')
        .to_return(status: 404)

      output = capture_stdout { task.invoke }
      
      expect(output).to include('Failed to fetch details for problem ID 1')
      expect(LeetCodeProblem.count).to eq(0)
    end
  end

  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
