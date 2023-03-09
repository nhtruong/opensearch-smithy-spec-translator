require_relative 'lib/translator'
require 'awesome_print'

translator = Translator.new('json_schema_spec/api', 'output')
translator.translate(['bulk'])

