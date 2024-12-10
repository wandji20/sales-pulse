module Notifications
  class Variant < Notification
    enum :message_type, NotificationTypes::VARIANT

    def message
      variant_name = subjectable.escape_value(:name)
      product_name = subjectable.product.escape_value(:name)
      variant_link = link(variant_name, edit_product_path(id: subjectable.product.id,
                  params: { variant_name: }))
      case message_type.to_sym
      when :low_stock
        I18n.t("notifications.#{message_type}_html",
              variant: variant_link, product: product_name, quantity: subjectable.quantity).html_safe
      when :out_of_stock
        I18n.t("notifications.#{message_type}_html", product: product_name, variant: variant_link).html_safe
      else
        raise "Unknown message_type"
      end
    end
  end
end
