class Word
  include Mongoid::Document
  field :value, type: String
  embedded_in :word_decorator
  
  def subsentence
    value
  end
  
  def self.analyze_sentence(sentence)
    strip_suffix = lambda {|w| w.gsub(/\..+$/, '')}
    match_word = lambda {|link, word| [link.lword, link.rword].any? {|w| w =~ /^#{word}(?:\..+)?$/}}
    {}.tap do |words|
      links, indicies = sentence.links.each_with_index.select {|l, i| l.label =~ /^W.?$/}, []
      until links.blank?
        link, index = *links.shift
        indices << index
      end
      # links = sentence.links.select {|l| l.label !~ /^W.?/ && [l.lword, l.rword].any? {|w| w =~ /^#{sentence.verb}\..+$/}}
      # links = sentence.links.select {|l| l.label !~ /^W.?/ && match_word.(l, sentence.verb)}
      # until links.blank?
      #   link = links.shift
      #   words[link.lword] = self.word_by_link_types[link.label.gsub(/[^A-Z]+$/, '')].new(value: strip_suffix.(link.lword))
      # end
    end.values
  end
  
  def self.link_types(*types)
    @link_types = types
  end
  
  def self.word_by_link_types
    @@word_by_link_types ||= self.descendants.inject({}){|h, c| c.link_types.inject(h) {|hs, t| hs[t] = c and hs}}.tap do |h|
      h.default_proc = lambda {|h,k| Word}
    end
  end
end
