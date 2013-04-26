module ListsHelper
  def path_for_new_list(list)
    if list.nil?
      new_list_path
    else
      new_list_list_path(list)
    end
  end
  def path_to_create_list(list)
    if list.nil?
      lists_path
    else
      list_lists_path(list)
    end
  end
end
