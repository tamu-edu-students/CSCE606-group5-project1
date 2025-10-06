# Adds additional problem metadata for better problem identification and display
class AddDetailsToLeetCodeProblems < ActiveRecord::Migration[8.0]
  def change
    add_column :leet_code_problems, :title_slug, :text    # URL-friendly problem identifier
    add_column :leet_code_problems, :description, :text  # Full problem description text
  end
end
