class Determiner < WordDecorator
  def self.link_types(*types)
    super(*%w{AL D DD DG DP DT})
  end
end
