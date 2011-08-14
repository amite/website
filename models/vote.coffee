_ = require 'underscore'
mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId
Person = mongoose.model 'Person'

VoteSchema = module.exports = new mongoose.Schema
  personId:
    type: ObjectId
    required: true
  teamId:
    type: ObjectId
    required: true
  type:
    type: String
    required: true
    enum: Person.ROLES
  comment: String
  utility: Number
  design: Number
  innovation: Number
  completeness: Number
  audit:
    remoteAddress: String
    remotePort: Number
    userAgent: String
    referrer: String
    accept: String
    requestAt: Number
    renderAt: Number
    hoverAt: Number
    responseAt: Number
VoteSchema.plugin require('mongoose-types').useTimestamps

# one vote per person-team-type
VoteSchema.index { personId: 1, teamId: 1, type: 1 }, { unique: true }
VoteSchema.index { personId: 1, updatedAt: -1 }
VoteSchema.index { teamId: 1, updatedAt: -1 }

VoteSchema.static 'dimensions',
  [ 'utility', 'design', 'innovation', 'completeness' ]
VoteSchema.static 'label', (dimension) ->
  switch dimension
    when 'utility'      then 'Utility/Fun'
    when 'design'       then 'Design'
    when 'innovation'   then 'Innovation'
    when 'completeness' then 'Completeness'

# associations
VoteSchema.static 'people', (votes, next) ->
  peopleIds = _.pluck votes, 'personId'
  return next() if peopleIds.length == 0
  # TODO only need certain fields probably; make `only` an argument
  Person.find _id: { '$in': peopleIds }, (err, people) ->
    return next err if err
    people = _.reduce people, ((h, p) -> h[p.id] = p; h), {}
    _.each votes, (v) -> v.person = people[v.personId]
    next()
VoteSchema.static 'teams', (votes, next) ->
  teamIds = _.pluck votes, 'teamId'
  return next() if teamIds.length == 0
  # TODO only need certain fields probably; make `only` an argument
  Team = mongoose.model 'Team'
  Team.find _id: { '$in': teamIds }, (err, teams) ->
    return next err if err
    teams = _.reduce teams, ((h, t) -> h[t.id] = t; h), {}
    _.each votes, (v) -> v.team = teams[v.teamId]
    next()

Vote = mongoose.model 'Vote', VoteSchema
