module NfseGyn
  class Sanitizer
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def clear
      return nil if value.nil?
      temp = I18n.transliterate(value)
      temp.tr!('-', ' ')
      temp.gsub!(/,|\./, '')
      temp.scan(/\w+|\s+/i).join
    end
  end
end
