# frozen_string_literal: true

require "webmock/rspec"

RSpec.describe "LLM::OpenAI" do
  subject(:openai) { LLM.openai("") }

  before(:each, :success) do
    stub_request(:post, "https://api.openai.com/v1/images/generations")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 200,
        body: {
          created: 1731499418,
          data: [
            {
              revised_prompt: "Create a detailed image showing a white Siamese cat. The cat has pierce blue eyes and slightly elongated ears. It should be sitting gracefully with its tail wrapped around its legs. The Siamese cat's unique color points on its ears, face, paws and tail are in a contrast with its creamy white fur. The background is peaceful and comforting, perhaps a softly lit quieter corner of a home, with tantalizing shadows and welcoming warm colors.",
              url: "https://oaidalleapiprodscus.blob.core.windows.net/private/org-onsUXMUK28Zzsh9Vv8iWj80q/user-VcliHUdhkKDdohyDGnVsJzYg/img-C5OCBxw69p4vKtcLLIlL9xCz.png?st=2024-11-13T11%3A03%3A37Z&se=2024-11-13T13%3A03%3A37Z&sp=r&sv=2024-08-04&sr=b&rscd=inline&rsct=image/png&skoid=d505667d-d6c1-4a0a-bac7-5c84a87759f8&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2024-11-12T19%3A49%3A57Z&ske=2024-11-13T19%3A49%3A57Z&sks=b&skv=2024-08-04&sig=9Bp9muevzDLdjymf%2BsnVuorprp6iCol/wI8Ih95xjhE%3D"
            }
          ]
        }.to_json
      )
  end

  before(:each, :unauthorized) do
    stub_request(:post, "https://api.openai.com/v1/images/generations")
      .with(headers: {"Content-Type" => "application/json"})
      .to_return(
        status: 401,
        body: '{
          "error": {
            "code": null,
            "message": "Invalid authorization header",
            "param": null,
            "type": "server_error"
          }
        }'
      )
  end

  context "with successful vision", :success do
    let(:vision) { openai.vision_generation("a white siamese cat") }

    it "returns a vision" do
      expect(vision).to be_a(LLM::Response::Vision)
    end

    it "has images" do
      expect(vision.images.first).to be_a(URI).and have_attributes(
        to_s: "https://oaidalleapiprodscus.blob.core.windows.net/private/org-onsUXMUK28Zzsh9Vv8iWj80q/user-VcliHUdhkKDdohyDGnVsJzYg/img-C5OCBxw69p4vKtcLLIlL9xCz.png?st=2024-11-13T11%3A03%3A37Z&se=2024-11-13T13%3A03%3A37Z&sp=r&sv=2024-08-04&sr=b&rscd=inline&rsct=image/png&skoid=d505667d-d6c1-4a0a-bac7-5c84a87759f8&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2024-11-12T19%3A49%3A57Z&ske=2024-11-13T19%3A49%3A57Z&sks=b&skv=2024-08-04&sig=9Bp9muevzDLdjymf%2BsnVuorprp6iCol/wI8Ih95xjhE%3D"
      )
    end
  end
end
