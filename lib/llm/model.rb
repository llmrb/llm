# frozen_string_literal: true

class LLM::Model < Struct.new(:name, :parameters, :description, :to_param, keyword_init: true)
  def to_json(*)
    to_param.to_json(*)
  end
end
