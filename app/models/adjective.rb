class Adjective < WordDecorator
  def self.link_types(*types)
    super(*%w{A AA AF AJ AM AN EA EB})
  end
end
