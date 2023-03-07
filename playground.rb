require_relative 'lib/operations_file_generator'

gen = OperationsFileGenerator.new('json_schema_spec/api/cat.health.json')
puts gen.render
