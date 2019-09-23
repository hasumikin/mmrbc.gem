module IntegerBytes
  refine Integer do
    def bytes(len = 1)
      sprintf("%#{len * 2}x", self).scan(/../).map{ |s| s.to_i(16) }
    end
  end
end
