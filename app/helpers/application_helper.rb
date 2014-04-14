module ApplicationHelper
  def markdown(input)
    emojified = Rumoji.decode(input)
    RDiscount.new(emojified).to_html.html_safe
  end
end
