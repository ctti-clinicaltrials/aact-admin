module Core
  class LoadEvent < Core::Base
    has_one  :verifier
  end
end
