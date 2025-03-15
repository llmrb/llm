# frozen_string_literal: true

require "webmock/rspec"

RSpec.describe "LLM::OpenAI" do
  subject(:openai) { LLM.openai("") }

  before(:each, :success) do
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 200,
        body: fixture("ok_completion.json"),
        headers: {"Content-Type" => "application/json"}
      )
  end

  before(:each, :unauthorized) do
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 401,
        body: fixture("unauthorized_completion.json"),
        headers: {"Content-Type" => "application/json"}
      )
  end

  before(:each, :bad_request) do
    stub_request(:post, "https://api.openai.com/v1/chat/completions")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 400,
        body: fixture("badrequest_completion.json")
      )
  end

  context "when given a successful response", :success do
    subject(:response) { openai.complete("Hello!", :user) }

    it "returns a completion" do
      expect(response).to be_a(LLM::Response::Completion)
    end

    it "returns a model" do
      expect(response.model).to eq("gpt-4o-mini-2024-07-18")
    end

    it "includes token usage" do
      expect(response).to have_attributes(
        prompt_tokens: 9,
        completion_tokens: 9,
        total_tokens: 18
      )
    end

    context "with a choice" do
      subject(:choice) { response.choices[0] }

      it "has choices" do
        expect(choice).to have_attributes(
          role: "assistant",
          content: "Hello! How can I assist you today?"
        )
      end

      it "includes the response" do
        expect(choice.extra[:completion]).to eq(response)
      end
    end
  end

  context "when given an unauthorized response", :unauthorized do
    subject(:response) { openai.complete(LLM::Message.new("Hello!", :user)) }

    it "raises an error" do
      expect { response }.to raise_error(LLM::Error::Unauthorized)
    end

    it "includes the response" do
      response
    rescue LLM::Error::Unauthorized => ex
      expect(ex.response).to be_kind_of(Net::HTTPResponse)
    end
  end

  context "when given a 'bad request' response", :bad_request do
    subject(:response) { openai.complete(URI("/foobar.exe"), :user) }

    it "raises an error" do
      expect { response }.to raise_error(LLM::Error::BadResponse)
    end

    it "includes the response" do
      response
    rescue LLM::Error => ex
      expect(ex.response).to be_instance_of(Net::HTTPBadRequest)
    end
  end

  def fixture(file)
    File.read File.join(fixtures, file)
  end

  def fixtures
    File.join(__dir__, "..", "fixtures", "responses", "openai", "completions")
  end
end
