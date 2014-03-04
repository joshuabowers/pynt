class Adverb < WordDecorator
  def self.link_types(*types)
    super(*%w{E EC EE EF EI EN EZ})
  end
end
