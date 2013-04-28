module TrainsHelper
  def percentage(x, total)
    "#{"%.2f" % ((x.to_f / total.to_f) * 100)}%"
  end
  def back_to_list
    link_to "Back to list", @list, class: "btn"
  end
end
