mongoose = require 'mongoose'
bcrypt = require 'bcrypt'

#
# User Schema
#

Schema = mongoose.Schema

UserSchema = new Schema
  name:
    type: String
    required: true
  email:
    type: String
    required: true
  username:
    type: String
    required: true
    unique: true
  password:
    type: String
    required: true
  created:
    type: Date
    default: Date.now

#
# Compare password method for authentication
#

UserSchema.methods.comparePassword = (candidatePassword, cb) ->
  bcrypt.compare candidatePassword, this.password, (err, isMatch) ->
    if err
      return cb err
    cb(null, isMatch)

#
# Hash password before saving
#

UserSchema.pre 'save', (next) ->
  user = this
  SALT_WORK_FACTOR = 10
  
  return next() if not user.isModified 'password'
  
  bcrypt.genSalt SALT_WORK_FACTOR, (err, salt) ->
    return next err if err
    bcrypt.hash user.password, salt, (err, hash) ->
      return next err if err

      user.password = hash
      next()
      return

    return


User = mongoose.model 'User', UserSchema