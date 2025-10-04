class AddDetailsToLeetCodeProblems < ActiveRecord::Migration[8.0]
  def change
    add_column :leet_code_problems, :title_slug, :text
    add_column :leet_code_problems, :description, :text
  end
end
