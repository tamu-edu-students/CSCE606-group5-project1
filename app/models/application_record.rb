# Base class for all application models
# Inherits from ActiveRecord::Base and serves as the primary abstract class
# All other models in the application inherit from this class
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class  # Designates this as the primary abstract class for the application
end
