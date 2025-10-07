require 'rails_helper'

RSpec.describe LeetCodeProblemsController, type: :controller do
  describe 'GET #index' do
    let(:user) { create(:user) }
    
    before do
      # Simulate user login by mocking current_user
      allow(controller).to receive(:current_user).and_return(user)
    end

    let!(:easy_problem) { create(:leet_code_problem, difficulty: 'Easy', tags: 'array, math') }
    let!(:medium_problem) { create(:leet_code_problem, difficulty: 'Medium', tags: 'string, dp') }
    let!(:hard_problem) { create(:leet_code_problem, difficulty: 'Hard', tags: 'graph, dfs') }
    let!(:extra_problems) { create_list(:leet_code_problem, 12, difficulty: 'Easy', tags: 'array') }

    it 'renders successfully with no filters' do
      get :index
      expect(response).to be_successful
      expect(assigns(:events).count).to eq(10) # paginated
      expect(assigns(:available_tags)).to include('array', 'math', 'string', 'dp', 'graph', 'dfs')
    end

    it 'filters by difficulty' do
      get :index, params: { difficulty: 'easy' }
      expect(response).to be_successful
      expect(assigns(:events).pluck(:difficulty).map(&:downcase).uniq).to eq(['easy'])
    end

    it 'filters by tags (array format)' do
      get :index, params: { tags: ['array', 'math'] }
      expect(response).to be_successful
      assigns(:events).each do |problem|
        expect(problem.tags).to include('array').and include('math')
      end
    end

    it 'filters by tags (comma-separated string)' do
      get :index, params: { tags: 'string,dp' }
      expect(response).to be_successful
      assigns(:events).each do |problem|
        expect(problem.tags).to include('string').and include('dp')
      end
    end

    it 'filters by difficulty and tags' do
      get :index, params: { difficulty: 'hard', tags: 'graph' }
      expect(response).to be_successful
      expect(assigns(:events).pluck(:difficulty).map(&:downcase).uniq).to eq(['hard'])
      assigns(:events).each do |problem|
        expect(problem.tags).to include('graph')
      end
    end

    it 'paginates results' do
      get :index, params: { page: 2 }
      expect(response).to be_successful
      expect(assigns(:events).count).to eq(5) # 15 total, 10 on page 1, 5 on page 2
    end

    it 'handles errors gracefully' do
      allow(LeetCodeProblem).to receive(:pluck).and_raise(StandardError.new('Test error'))
      expect(Rails.logger).to receive(:error).with(/Leetcode error: Test error/)
      get :index
      expect(response).to be_successful
      expect(flash.now[:alert]).to eq('Failed to load leet problems.')
      expect(assigns(:events)).to eq([])
    end

    it 'extracts available tags correctly' do
      get :index
      expect(response).to be_successful
      expect(assigns(:available_tags)).to match_array(%w[array math string dp graph dfs])
    end
  end
end