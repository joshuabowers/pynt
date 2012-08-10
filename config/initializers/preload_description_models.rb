if Rails.env.development?
  %w{description entry conditional branch triggered}.each do |c|
    require_dependency Rails.root.join("app", "models", "#{c}.rb").to_s
  end
end