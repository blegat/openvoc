module TrainsHelper
  def percentage(x, total)
    "#{sprintf("%.2f", (x.to_f / total.to_f) * 100)}%"
  end
end
