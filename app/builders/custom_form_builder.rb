# app/helpers/form_builder.rb
class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options = {})
    form_group(method, options) do
      super(method, form_control_options(method, options))
    end
  end

  def email_field(method, options = {})
    form_group(method, options) do
      super(method, form_control_options(method, options))
    end
  end

  def password_field(method, options = {})
    form_group(method, options) do
      super(method, form_control_options(method, options))
    end
  end

  def select(method, choices = nil, options = {}, html_options = {})
    form_group(method, options) do
      super(method, choices, options, form_control_options(method, html_options))
    end
  end

  private

  def form_group(method, options = {}, &block)
    label_text = options.delete(:label)
    has_errors = object.errors[method].any? if object.present?

    @template.content_tag(:div, class: [ "form-group" ]) do
      label = label(method, label_text || method.to_s.titleize, class: "form-label") if label_text != false
      field = @template.capture(&block) # get html string from generated input from super
      error = error_message(method) if has_errors

      (label.to_s + field + error.to_s).html_safe
    end
  end

  def form_control_options(method, options)
    options[:class] = [ options[:class], "form-control" ].compact.join(" ")
    return options unless object

    options[:class] << " is-invalid" if object.errors[method]&.any?
    options
  end

  def error_message(method)
    return unless object.present?

    @template.content_tag(:div, class: "invalid-feedback") do
      object.errors[method].each do |message|
        @template.content_tag(:span, message)
      end
    end
  end
end
