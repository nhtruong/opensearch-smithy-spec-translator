require_relative 'lib/translator'
require_relative 'lib/action'
require 'awesome_print'

translator = Translator.new('json_schema_spec/api', 'test_output')
translator.translate




# action = Action.new(Pathname.new('json_schema_spec/api/index.json'))
# ap action.operations.first.path_params
