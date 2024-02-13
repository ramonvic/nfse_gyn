class Object
  def try(method_name, *args, &block)
    if method_name.nil? || !respond_to?(method_name)
      nil
    else
      public_send(method_name, *args, &block)
    end
  end

  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end

  def present?
    !blank?
  end
end

class String
  def squish
    strip.gsub(/\s+/, ' ')
  end
end
