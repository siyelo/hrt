module Admin::CodesHelper
  def codes_for_type(code_type)
    code_types = [Code::PURPOSES, Code::INPUTS,
                  Code::LOCATIONS, Code::BENEFICIARIES].detect do |ct|
      ct.include?(code_type)
    end

    Code.with_types(code_types).with_last_version
  end
end
