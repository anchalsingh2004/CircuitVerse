# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Contests#close_contest edge-cases", type: :request do
  let(:admin) { create(:user, admin: true) }

  before { sign_in admin; enable_contests! }

  context "when the contest is already completed" do
    let(:contest) { create(:contest, status: :completed) }

    it "just redirects" do
      put close_contest_path(contest)

      expect(response).to redirect_to(contest_page_path(contest))
      expect(contest.reload.status).to eq("completed")
    end
  end

  context "when the DB update fails" do
    let(:contest) { create(:contest, status: :live) }

    before do
      allow_any_instance_of(Contest).to receive(:update).and_return(false)

      allow_any_instance_of(ContestsController).to receive(:render) do |controller, *|
        controller.head :unprocessable_entity
      end
    end

    it "responds with 422" do
      put close_contest_path(contest)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
