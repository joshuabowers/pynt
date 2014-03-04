class WordDecorator < Word
  embeds_one :word, cascade_callbacks: true
  
  def subsentence
    "#{super} #{word.subsentence}"
  end
end
