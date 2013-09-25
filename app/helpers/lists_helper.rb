module ListsHelper
  def ext_to_mime()
    {
      ".ods" =>
      "application/vnd.oasis.opendocument.spreadsheet",
        ".csv" =>
      "text/csv",
        ".xls" =>
      "application/vnd.ms-excel",
        ".xlsx" =>
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    }
  end
  def supported()
    [
      ["OpenDocument Spreadsheet (.ods)",
        ".ods"],
      ["Comma-separated values (.csv)",
        ".csv"],
      ["Excel Spreadsheet (.xls)",
        ".xls"],
      ["Excel Workbook (.xlsx)",
        ".xlsx"]
    ]
  end
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
