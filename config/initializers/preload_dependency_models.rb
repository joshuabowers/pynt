if Rails.env.development?
  %w{description plain entry conditional branch triggered word adjective adverb determiner}.each do |c|
    require_dependency Rails.root.join("app", "models", "#{c}.rb").to_s
  end
end