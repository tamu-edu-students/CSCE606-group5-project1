require 'rails_helper'

RSpec.describe StatisticsController, type: :controller do
  describe 'GET #show' do
    let(:user) { create(:user) }
    let(:weekly_stats_service_double) { instance_double(Reports::WeeklyStats) }
    let(:stats_result) do
      {
        weekly_solved_count: 5,
        total_solved_all_time: 100,
        current_streak_days: 3,
        highlight: "Hardest problem this week: Two Sum"
      }
    end

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(Reports::WeeklyStats).to receive(:new).with(user).and_return(weekly_stats_service_double)
      allow(weekly_stats_service_double).to receive(:call).and_return(stats_result)
      get :show
    end

    it 'responds with a success status' do
      expect(response).to have_http_status(:success)
    end

    it 'renders the show template' do
      expect(response).to render_template(:show)
    end

    it 'initializes the weekly stats service with the current user' do
      expect(Reports::WeeklyStats).to have_received(:new).with(user)
    end

    it 'calls the service and assigns the result to @weekly_stats' do
      expect(weekly_stats_service_double).to have_received(:call)
      expect(assigns(:weekly_stats)).to eq(stats_result)
    end

    it 'assigns the backward-compatible @stats hash correctly' do
      expected_stats_hash = {
        total: 100,
        easy: 0,
        medium: 0,
        hard: 0
      }
      expect(assigns(:stats)).to eq(expected_stats_hash)
    end

    it 'assigns the backward-compatible @recent_stats hash correctly' do
      expected_recent_stats_hash = {
        week: 5,
        month: 0
      }
      expect(assigns(:recent_stats)).to eq(expected_recent_stats_hash)
    end
  end
end
