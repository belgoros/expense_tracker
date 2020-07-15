require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }
    let(:expense) { {'some' => 'data'} }

    describe 'GET /expenses/:date' do
      context 'when expenses exist on the given date' do

        before do
          allow(ledger).to receive(:expenses_on)
            .with('2020-07-28')
            .and_return(['expense-1', 'expense-2'])
        end

        it 'returns the expense records as JSON' do
          get "/expenses/2020-07-28"
          expect(parsed_response).to eq(['expense-1', 'expense-2'])
        end

        it 'responds with a 200 (OK)' do
          get "/expenses/2020-07-28"
          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with('2020-07-28')
            .and_return([])
        end

        it 'returns an empty array as JSON' do
          get '/expenses/2020-07-28'
          expect(parsed_response).to eq []
        end

        it 'responds with a 200 (OK)' do
          get '/expenses/2020-07-28'
          expect(last_response.status).to eq(200)
        end
      end
    end

    describe "POST /expenses" do
      context "when the expense is successfully recorded" do
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(true, 417, nil))
        end

        it "returns the expense id" do
          post '/expenses', JSON.generate(expense)
          expect(parsed_response).to include('expense_id' => 417)
        end

        it "responds with 200 (OK)" do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end

      context "when the expense fails validation" do
        before do
          allow(ledger).to receive(:record)
            .with(expense)
            .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)
          expect(parsed_response).to include('error' => 'Expense incomplete')
        end

        it 'responds with 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end

    def parsed_response
      JSON.parse(last_response.body)
    end
  end
end
