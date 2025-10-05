require 'rails_helper'

RSpec.describe StatisticsController, type: :controller do
  let(:user) { create(:user) }

  before do
    session[:user_id] = user.id
  end

  describe 'GET #show' do
    context 'when user has no LeetCode username' do
      it 'assigns default stats' do
        get :show
        expect(assigns(:stats)[:total]).to eq(0)
        expect(assigns(:recent_stats)[:week]).to eq(0)
      end

      it 'renders the show template' do
        get :show
        expect(response).to render_template(:show)
      end
    end

    context 'when user has a LeetCode username' do
      let(:user) { create(:user, leetcode_username: 'testuser') }
      let(:fetcher_double) { instance_double(Leetcode::FetchStats) }

      before do
        allow(Leetcode::FetchStats).to receive(:new).and_return(fetcher_double)
      end

      context 'when stats are fetched successfully' do
        let(:solved_stats) { { total: 10, easy: 5, medium: 4, hard: 1 } }
        let(:calendar_data) do
          {
            "submissionCalendar" => {
              (Time.current - 2.days).to_i.to_s => 3, # In the last week/month
              (Time.current - 10.days).to_i.to_s => 2, # In the last month
              (Time.current - 40.days).to_i.to_s => 5 # Outside the last month
            }
          }
        end

        before do
          allow(fetcher_double).to receive(:solved).with('testuser').and_return(solved_stats)
          allow(fetcher_double).to receive(:calendar).with('testuser').and_return(calendar_data)
        end

        it 'assigns the fetched stats' do
          get :show
          expect(assigns(:stats)).to eq(solved_stats)
        end

        it 'calculates and assigns recent stats correctly' do
          get :show
          expect(assigns(:recent_stats)).to eq({ week: 1, month: 2 })
        end

        it 'renders the show template' do
          get :show
          expect(response).to render_template(:show)
        end
      end

      context 'when fetching stats fails' do
        before do
          allow(fetcher_double).to receive(:solved).and_raise(StandardError, 'API is down')
        end

        it 'sets an error message' do
          get :show
          expect(assigns(:error_message)).to eq('Unable to fetch LeetCode stats: API is down')
        end

        it 'assigns default stats' do
          get :show
          expect(assigns(:stats)[:total]).to eq(0)
          expect(assigns(:recent_stats)[:week]).to eq(0)
        end
      end
    end
  end
end
