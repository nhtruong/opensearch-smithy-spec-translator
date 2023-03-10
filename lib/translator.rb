# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
#
# Modifications Copyright OpenSearch Contributors. See
# GitHub history for details.

# frozen_string_literal: true

require_relative 'params_repository'
require_relative 'params_file_generator'
require_relative 'operations_file_generator'

# Translate legacy spec to smithy models
class Translator
  def initialize(input, output)
    @input = Pathname input
    @output = Pathname output
    @params = ParamsRepository.new
  end

  def translate(groups = nil)
    pathnames = if groups.nil?
                  @input.children
                else
                  groups.map { |basename| @input.join "#{basename}.json" }
                end
    generate_operations_files pathnames
    generate_params_files
  end

  private

  def generate_operations_files(pathnames)
    pathnames.map do |pathname|
      op = OperationsFileGenerator.new pathname
      @params.add_many op.action.query_params
    end
  end

  def generate_params_files
    puts ParamsFileGenerator.new(@params.filter_by_type(:integer), :simple).render
    puts ParamsFileGenerator.new(@params.filter_by_type(:string), :simple).render
    puts ParamsFileGenerator.new(@params.filter_by_type(:boolean), :simple).render
    puts ParamsFileGenerator.new(@params.filter_by_type(:list), :list).render
    puts ParamsFileGenerator.new(@params.filter_by_type(:enum), :enum).render
  end
end
