require_relative 'lib/translator'
require 'awesome_print'

translator = Translator.new('json_schema_spec/api', 'test_output')
translator.translate

