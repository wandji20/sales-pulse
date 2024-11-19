# app/helpers/form_builder.rb
class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(method, options = {})
    form_group(method, options) do
      super(method, form_control_options(method, options))
    end
  end

  def number_field(method, options = {})
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

  def collection_radio_buttons(method, collection, value_method, text_method, options = {}, html_options = {})
    form_group(method, options) do
      html_options[:class] = [ html_options[:class], "form-check-input" ].compact.join(" ")
      html_options[:class] << " is-invalid" if object&.errors[method]&.any?

      @template.collection_radio_buttons(
        object_name, method, collection, value_method, text_method,
        options.reverse_merge(item_wrapper_tag: :div, item_wrapper_class: "form-check")
      ) do |b|
        @template.content_tag(:div, class: "form-check-wrapper") do
          b.radio_button(html_options) + b.label(class: "form-check-label")
        end
      end
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
      @template.safe_join(
        object.errors[method].map do |message|
          @template.content_tag(:span, message)
        end
      )
    end
  end
end
