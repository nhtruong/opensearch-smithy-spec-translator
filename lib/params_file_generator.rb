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
  def initialize(params, category)
    @params = params
    @category = category
    super({})
  end

  def simples
    return unless @category == :simple
    @params.map do |param|
      param.traits.merge({
        smithy_name: param.smithy_name,
        smithy_type: param.smithy_type,
        _blank_line: param.name != @params.last.name
      })
    end
  end

  def string_lists
    return unless @category == :string_list
    @params.map do |param|
      param.traits.merge({ smithy_name: param.smithy_name, _blank_line: param.name != @params.last.name })
    end
  end

  def enums
    return unless @category == :enum
    @params.map do |param|
      param.traits.merge({
        smithy_name: param.smithy_name,
        options: param.options,
        _blank_line: param.name != @params.last.name
      })
    end
  end

  def enum_lists
    return unless @category == :enum_list
    @params.map do |param|
      param.traits.merge({
        smithy_name: param.smithy_name,
        member_smithy_name: "#{param.smithy_name}_Member",
        options: param.options,
        _blank_line: param.name != @params.last.name
      })
    end
  end
end
