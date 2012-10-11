class CustomFormBuilder < ActionView::Helpers::FormBuilder
  # NOTE: maybe this is possible to be defined as method
  # which will bring more flexibility in the markup
  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    if html_tag =~ /type="hidden"/ || html_tag =~ /<label/
      html_tag
    else
      error_tag = '<p class="input-errors">' +
        [instance.error_message].join(', ') +
        '</p>'
      "<div class='input-box'>#{html_tag}#{error_tag}</div>".html_safe
    end
  end

  %w[text_field select collection_select password_field text_area file_field].
    each do |method_name|
      define_method(method_name) do |field_name, *args|
        arguements = args.select{ |a| a.class == Hash }.inject({}){ |h, e| h.merge(e) }
        if arguements.present? && arguements[:hint]
          hint = @template.content_tag(:p, arguements[:hint], class: 'input-hints')
        else
          hint = ""
        end

        @template.content_tag(:li, field_label(field_name, *args) +
                              super(field_name, *args) + hint,
                              arguements[:wrapper_html])
      end
    end

  def check_box(field_name, *args)
    @template.content_tag(:p, super + " " + field_error(field_name) +
                          field_label(field_name, *args))
  end

  def submit(*args)
    @template.content_tag(:li, super, class: 'commit')
  end

  def error_messages(*args)
    @template.render_error_messages(object, *args)
  end

  private

  def field_error(field_name)
    if object.errors[field_name].present?
      @template.content_tag(:span,
                            [object.errors[field_name].flatten.first.sub(/^\^/, ''),
                            class: 'error_message'])
    else
      ''
    end
  end

  def field_label(field_name, *args)
    options = args.extract_options!
    label_options = options[:label_html] || {}
    abbr = label_options[:required] ? '<abbr title="required">*</abbr>'.html_safe : ''
    label("#{field_name}#{abbr}".html_safe, "#{options[:label]}#{abbr}".html_safe, label_options)
  end

  def objectify_options(options)
    super.except(:label, :required, :hint, :label_html, :wrapper_html)
  end
end
