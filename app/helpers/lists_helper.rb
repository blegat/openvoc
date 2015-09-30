module ListsHelper
  def path_for_new_list(list, group)
    if group.nil?
      if list.nil?
        new_list_path
      else
        new_list_list_path(list)
      end
    else
      if list.nil?
        new_group_list_path
      else
        new_group_list_list_path(group,list)
      end
    end
  end
  def path_to_create_list(list, group)
    if group.nil?
      if list.nil?
        lists_path
      else
        list_lists_path(list)
      end
    else
      if list.nil?
        group_lists_path
      else
        group_list_lists_path(group,list)
      end
    end
  end
  def path_for_list(list,group)
    if group.nil?
      list_path(list)
    else
      group_list_path(group,list)
    end
  end
  def path_for_root_list(group)
    if group.nil?
      lists_path
    else
      group_lists_path(group)
    end
  end
  def path_for_list_moving(list,group)
    if group.nil?
      list_moving_path(list)
    else
      group_list_moving_path(group,list)
    end
  end
  def path_for_list_move(list,group)
    if group.nil?
      list_move_path(list)
    else
      group_list_move_path(group,list)
    end
  end
  def path_for_list_export(list,group)
    if group.nil?
      list_export_path(list)
    else
      group_list_export_path(group,list)
    end
  end
  def path_for_list_exporting(list,group)
    if group.nil?
      list_exporting_path(list)
    else
      group_list_exporting_path(group,list)
    end
  end
  def path_for_edit_list(list,group)
    if group.nil?
      edit_list_path(list)
    else
      edit_group_list_path(group,list)
    end
  end
  def path_for_edit_list(list,group)
    if group.nil?
      edit_list_path(list)
    else
      edit_group_list_path(group,list)
    end
  end
  def path_for_list_prepare_data_to_add(list,group)
    if group.nil?
      list_prepare_data_to_add_path(list)
    else
      group_list_prepare_data_to_add_path(group,list)
    end
  end
  def path_for_list_add_data(list,group)
    if group.nil?
      list_add_data_path(list)
    else
      group_list_add_data_path(group,list)
    end
  end
end
