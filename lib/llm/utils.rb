# frozen_string_literal: true

##
# @private
module LLM::Utils
  def camelcase(key)
    key.to_s
      .split("_")
      .map.with_index { (_2 > 0) ? _1.capitalize : _1 }
      .join
  end

  def snakecase(key)
    key
      .split(/([A-Z])/)
      .map { (_1.size == 1) ? "_#{_1.downcase}" : _1 }
      .join
  end
end
