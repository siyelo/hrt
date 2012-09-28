module Shared::OutlaysHelper
  ACTIVITY_TABS = {
    :implementers => 'Implementers',
    :locations => 'Locations',
    :purposes => 'Purposes',
    :inputs => 'Inputs',
    :outputs => 'Outputs, Targets & Beneficiaries'
  }

  INDIRECT_COST_TABS = {
    :implementers => 'Implementers',
    :locations => 'Locations',
    :inputs => 'Inputs'
  }

  def sorted_project_select(response, klass, length = 60)
    list = response.projects.sort_by{ |p| p.name }.collect do |u|
      [ truncate(u.name, :length => length), u.id ]
    end
    blank_name = klass == "OtherCost" ? "Not project-specific" :  ""
    list.insert(0,[blank_name, nil])
  end

  def selected_project(project)
    if params[:project_id].present?
      params[:project_id]
    else
      project ? project.id : nil
    end
  end

  def tab_class(tab)
    if params[:mode]
      params[:mode] == (tab.to_s) ? 'selected' : nil
    else
      'selected' if tab == :implementers
    end
  end

  # other costs do not show Purposes/Inputs/Outputs tabs
  def save_and_add_button_text(current_step, outlay)
    current_step ||= 'implementers'
    current_index = tabs(outlay).keys.index(current_step.to_sym)
    if current_index == tabs(outlay).size - 1
      "Save & Go to Overview >"
    else
      "Save & Add #{tabs(outlay).values[current_index + 1]} >"
    end
  end

  def tabs(outlay)
    if outlay.class == Activity
      Shared::OutlaysHelper::ACTIVITY_TABS
    else
      Shared::OutlaysHelper::INDIRECT_COST_TABS
    end
  end

  def last_version_beneficiaries
    last_version = Beneficiary.maximum(:version)
    Beneficiary.with_version(last_version)
  end
end
