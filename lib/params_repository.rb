# SPDX-License-Identifier: Apache-2.0
#
# The OpenSearch Contributors require contributions made to
# this file be licensed under the Apache-2.0 license or a
# compatible open source license.
#
# Modifications Copyright OpenSearch Contributors. See
# GitHub history for details.

# frozen_string_literal: true

require 'ostruct'
require 'forwardable'
require 'active_support/all'

# Repository for shared params
class ParamsRepository
  attr_reader :repo

  def initialize
    @repo = custom_params
  end

  # @param [Array<Parameter>] params
  def add_many(params)
    params.each { |param| add_one param }
  end

  # @param [Parameter] param
  def add_one(param)
    return if param.unique_description? || param.unique_deprecation? || param.skip_repo?
    name = param.name
    spec = param.spec.deep_dup
    spec.delete_field(:required) unless spec.required.nil?
    # TODO: Handle Collisions
    # raise collision_message(name, spec) if @repo.include?(name) && @repo[name].spec != spec
    @repo[name] = param
  end

  def filter_by_type(type)
    @repo.values
         .select { |param| param.smithy_type == type.to_s }
         .sort_by { |param| [param.type, param.name] }
  end

  private

  def collision_message(name, spec)
    "#{name} has already been used \n" \
      "#{spec} \n" \
      "#{@repo[name].spec} \n"
  end

  def custom_params
    {
      'requests_per_second' => OpenStruct.new(
        type: 'integer',
        description: 'The throttle for this request in sub-requests per second. -1 means no throttle.'
      ),
      'explain' => OpenStruct.new(
        type: 'boolean'
      ),
      'size' => OpenStruct.new(
        type: 'integer'
      ),
      'detailed' => OpenStruct.new(
        type: 'boolean',
        default: false
      ),
      'ignore_unavailable' => OpenStruct.new(
        type: 'boolean',
        default: false,
        description: 'Whether specified concrete indices should be ignored when unavailable (missing or closed)'
      ),
      'allow_no_indices' => OpenStruct.new(
        type: 'boolean',
        default: false,
        description: 'Whether to ignore if a wildcard indices expression resolves into no concrete indices. (This includes `_all` string or when no indices have been specified)'
      ),
      'active_only' => OpenStruct.new(
        type: 'boolean',
        default: false
      ),
      'verbose' => OpenStruct.new(
        type: 'boolean',
        default: false
      ),
      'refresh_boolean' => OpenStruct.new(
        type: 'boolean'
      )
    }
  end
end

