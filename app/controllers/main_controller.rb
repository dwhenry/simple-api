class MainController < ApplicationController
  def index
    css = %{
    <style>
      table {
        border-spacing: 0px;
        border-collapse: separate;
      }
      table thead {
        text-weight: body;
        background-color: #ccc;
      }
      td, th {
        padding: 8px 15px;
        border-bottom: 1px solid #ccc;
      }
    </style>
    }
    text = File.read(Rails.root.join('README.md'))
    html = Kramdown::Document.new(text).to_html
    render text: css + html
  end
end
