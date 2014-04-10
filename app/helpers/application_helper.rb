module ApplicationHelper
  def markdown(input)
    RDiscount.new(input).to_html.html_safe
  end
end
