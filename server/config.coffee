config =
  name: 'tablestakes'
  secret: 'secretstring'
  port: process.env.PORT or 5000
  css: 'scss'

if process.env.NODE_ENV is 'testing'
  config.port = 5001

module.exports = config
