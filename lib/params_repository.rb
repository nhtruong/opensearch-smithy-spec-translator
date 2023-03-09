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
  attr_reader :repos

  delegate :simples, :lists, :times, :enums, :unions, to: :repos

  def initialize
    @repos = OpenStruct.new(
      simples: {},
      lists: {},
      times: {},
      enums: {},
      unions: {}
    )
  end

  def add_many(params)
    params.each { |name, info| add_one name, info }
  end

  def add_one(name, info)
    repo =  case info.type
            when 'string', 'integer', 'boolean' then simples
            when 'list' then lists
            when 'time' then times
            when 'enum' then enums
            when 'number|string' then unions
            else raise "Unrecognized Data Type: #{info.type}"
            end
    # TODO: Handle Collisions
    # raise collision_message(repo, name, info) if repo.include?(name) && repo[name] != info
    repo[name] = info
  end

  private

  def collision_message(repo, name, info)
    "#{name} has already been used \n" \
      "#{info.to_json} \n" \
      "#{repo[name].to_json} \n"
  end
end

