# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
#
# Modifications Copyright OpenSearch Contributors. See
# GitHub history for details.

# frozen_string_literal: true

require_relative 'base_generator'
require_relative 'parameter'

# Generator for operations.smithy
class ParamsFileGenerator < BaseGenerator
  self.template_file = './templates/params.mustache'

  # @param [Array<Parameter>] params
  # @param [Symbol] category
  def initialize(params, category = nil)
    @params = params
    @category = category || @params.first&.category
    super({})
  end

  def simples
    return unless @category == :simples
    @params.map do |param|
      param.traits.merge({
        name: param.name,
        smithy_type: param.smithy_type
      })
    end
  end

  def lists
    return unless @category == :lists
    @params.map do |param|
      param.traits.merge({ name: param.name })
    end
  end

  def enums
    return unless @category == :enums
    @params.map do |param|
      param.traits.merge({
        name: param.name,
        options: param.options
      })
    end
  end
end
